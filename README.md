# Check-it

<p align="center">
  <img src="assets/icon/icon.png" alt="Check-it" width="120">
</p>

<p align="center">
  <b>Signalement et blocage des numéros frauduleux pour commerçants algériens.</b>
</p>

---

## Le problème

Un commerçant reçoit un appel d'un faux support bancaire, d'un faux livreur ou d'un
escroc par SMS. Il décroche, il donne son numéro de carte ou il valide un paiement
MCTP sur un lien envoyé par message. La fraude se joue sur un écran, en trente
secondes, et personne n'a la culture nécessaire pour la repérer.

Les annuaires inversés listent à jour les numéros déjà signalés par la communauté.
la communauté. Check-it fait l'inverse : l'utilisateur **signale** un numéro, **documente**
la fraude avec une capture d'écran, et la communauté voit immédiatement que le numéro
est déjà connu.

## Ce que fait l'application

| Fonction | Détail |
|---|---|
| **Signalement communautaire** | Chaque utilisateur déclare un numéro, un motif et une gravité. La base est partagée et temps réel. |
| **Capture d'écran** | La preuve de la fraude est envoyée dans le signalement et stockée côté serveur. |
| **Nombre de signalements** | Le nombre de signalements par numéro s'affiche avant de décrocher. |
| **Blocage** | Blocage d'un numéro depuis le journal d'appels. |
| **Compte utilisateur** | Connexion Google, profil persistant. |
| **Multilingue** | Interface en français, arabe et anglais, avec RTL. |
| **Notifications** | Push Firebase pour les alertes. |
| **Publicité** | Bannière et interstitiel Google AdMob, sans impact sur la functionality. |

## Architecture

```
lib/
├── main.dart                  Initialisation Firebase / Supabase / AdMob / locale
├── AppLocalizations.dart      Arborescence de traduction
├── My_widgets.dart            Composants partagés
├── checkit/
│   ├── MyApp.dart             MaterialApp, thème clair/sombre, routage
│   ├── home.dart              Écran d'accueil
│   ├── HomePage.dart          Écran principal, signalement, journal, profil
│   ├── EnhancedCallScreen.dart  Détail d'un appel et historique du numéro
│   ├── AuthProvider.dart      État d'authentification (Firebase Auth)
│   ├── provider.dart          SignalementProvider (Realtime Database)
│   ├── providerF.dart         SignalementProviderSupabase (Postgres + RLS)
│   ├── Models.dart            Modèle Signalement
│   ├── users.dart             Profils et historique
│   ├── binance.dart           Réglages de notification
│   ├── admobHelper.dart       Chargement des annonces
│   ├── admob/                 Exemples et variantes AdMob
│   └── widgets/               Motifs de signalement, fonctions utilitaires
```

### Choix techniques

**Deux backends de signalement coexistent.** `provider.dart` écrit dans Firebase
Realtime Database, `providerF.dart` écrit dans Supabase Postgres. Les deux lisent et
écrivent la collection `signalements`. C'est une migration en cours, pas une
intentionalité : `HomePage.dart` consomme encore les deux. Il faudra trancher avant
d'ajouter une fonctionnalité, sinon les signalements se dupliquent.

**Supabase est configuré en dur dans `main.dart`.** L'URL et la clé anon sont en
constante dans le code. La clé anon est publique par conception, mais la mettre dans
le dépôt empêche de tourner contre plusieurs environnements. À sortir dans
`--dart-define`.

**Google Mobile Ads est désactivable.** L'identifiant AdMob est dans le manifest.
Supprimer la ligne et le bloc `MobileAds.instance.initialize()` retire la pub sans
toucher au reste.

## Stack technique

| Couche | Choix |
|---|---|
| Framework | Flutter 3.44 / Dart 3.12 |
| Auth | Firebase Auth (Google) |
| Base temps réel | Firebase Realtime Database |
| Base relationnelle | Supabase (Postgres + RLS + Storage) |
| Push | Firebase Cloud Messaging |
| Publicité | Google Mobile Ads 6 |
| Navigation / État | Provider |
| Cache image | cached_network_image |
| UI | Material 3, Lottie, shimmer |

## Prérequis

- Flutter `3.44.0` ou supérieur
- Android Studio avec SDK 37
- JDK 17
- Un projet Firebase et un projet Supabase existants

## Installation

```bash
git clone git@github.com:Connacri/check31.git
cd check31
flutter pub get
flutter run
```

## Configuration

### Firebase

Le fichier `android/app/google-services.json` est nécessaire. Il est déjà présent
et relié au projet `check31-a2fdf` via `firebase.json`. Pour pointer vers un autre
projet :

```bash
flutterfire configure
```

Les permissions Android demandées sont `INTERNET`, `WAKE_LOCK`, `FOREGROUND_SERVICE`,
`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` et `READ_CALL_LOG`.

### Supabase

Table attendue, voir `providerF.dart` :

```sql
create table signalements (
  id          bigint generated always as identity primary key,
  user        text not null,
  numero      text not null,
  description text,
  signalePar  text not null,
  motif       text not null,
  gravite     int  not null,
  date        timestamptz not null default now()
);

alter table signalements enable row level security;
```

La clé anon vit dans `lib/main.dart`. Sans elle l'application démarre mais toute
lecture de signalement échoue.

### Signature Android

Le keystore n'est pas dans le dépôt. Créer `android/key.properties` :

```properties
storeFile=../upload-keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Le build release utilise cette configuration si elle existe, sinon il retombe sur la
clé debug. Un AAB signé en debug est refusé par Google Play.

## Build et release

**Aucun build n'est produit en local.** Tout part de GitHub Actions.

Chaque `push` sur `main` déclenche `.github/workflows/release.yml`, qui compile et
publie une GitHub Release :

| Artefact | Usage |
|---|---|
| `check31-<tag>.aab` | Google Play Console |
| `check31-<tag>.apk` | Installation directe, toutes architectures |
| `check31-<tag>-arm64-v8a.apk` | Téléphones modernes |
| `check31-<tag>-armeabi-v7a.apk` | Téléphones 32 bits |
| `check31-<tag>-x86_64.apk` | Émulateur |
| `check31-<tag>-web.zip` | Contenu `build/web` pour un hébergement |

```bash
git push origin main          # déclenche le build
```

Le tag est `v<version>-build<numéro_de_run>`, donc unique par push et jamais
écrasé. Le `versionCode` est le numéro de run : strictement croissant, ce qu'exige
Play Console.

### Secrets requis

À créer dans Settings → Secrets and variables → Actions du dépôt :

| Secret | Contenu |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` du keystore |
| `ANDROID_KEY_ALIAS` | `keyAlias` du keystore |
| `ANDROID_KEY_PASSWORD` | `keyPassword` du keystore |

Sans ces quatre secrets, le build aboutit mais l'AAB est signé avec la clé debug et
sera refusé à la publication. Le workflow émet un warning dans ce cas.

### Cible API

`compileSdk` et `targetSdk` sont à 36 (Android 16). Google Play bloque les mises à
jour d'applications sous le niveau d'API de l'année précédente à partir du
1 novembre 2026.

| Outil | Version |
|---|---|
| Gradle | 8.14.3 |
| Android Gradle Plugin | 8.11.1 |
| Kotlin | 2.2.20 |
| Java | 17 |
| NDK | 28.2.13676358 |

### Site web

`public/` est le dossier servi par Firebase Hosting. Il contient la page de
présentation, distincte du build Flutter web.

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only hosting
```

## Notes sur les dépendances

`font_awesome_flutter` est en 11.x. Depuis cette version, `FaIconData` n'implémente
plus `IconData`, parce que `IconData` est devenu `final` dans Flutter. Un `Icon`
standard ne peut plus afficher une icône Font Awesome, il faut `FaIcon`. Mélanger les
deux versions ne compile pas.

`intl` est épinglé en 0.20.x par `flutter_localizations`. Toute version antérieure
fait échouer la résolution.

## Structure du dépôt

```
.github/workflows/release.yml   Build et publication des releases
android/                        Projet Gradle
ios/                            Projet iOS
lib/                            Code Dart
assets/                         Images, polices, Lottie
public/                         Site de présentation (Firebase Hosting)
web/                            Gabarit du build Flutter web
firebase.json                   Configuration Firebase
storage.rules                   Règles de sécurité du bucket
```

## Stack technique côté serveur

| Service | Rôle |
|---|---|
| Firebase Auth | Authentification Google |
| Firebase Realtime Database | Signalements en temps réel |
| Firebase Storage | Captures d'écran des signalements |
| Supabase | Base Postgres des signalements, avec RLS |
| Firebase Cloud Messaging | Notifications push |

## Licence

Propriétaire. Tous droits réservés.