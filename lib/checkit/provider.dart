import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Models.dart';

final firebaseApp = Firebase.app();

class SignalementProvider with ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("signalements");

  // final _db = FirebaseDatabase.instanceFor(
  //         app: firebaseApp,
  //         databaseURL: 'https://walletdz-d12e0-default-rtdb.firebaseio.com/')
  //     .ref('signalements');

  // Stockage des signalements par numéro
  Map<String, List<Signalement>> _signalementsParNumero = {};

  Map<String, List<Signalement>> get signalementsParNumero =>
      _signalementsParNumero;

  /// Écoute les mises à jour en temps réel
  void chargerSignalements() {
    _db.onValue.listen((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      _signalementsParNumero = (data ?? {}).map<String, List<Signalement>>((
        key,
        value,
      ) {
        final signalements =
            (value as Map? ?? {}).values
                .whereType<Map<dynamic, dynamic>>()
                .map(Signalement.fromJson)
                .toList();
        return MapEntry(key.toString(), signalements);
      });
      notifyListeners();
    });
  }

  /// Ajoute un signalement dans Firebase et met à jour l'état
  Future<void> ajouterSignalement(Signalement signalement) async {
    try {
      final ref = _db.child(signalement.numero.toString()).push();
      await ref.set(signalement.toJson());
      print('Signalement ajouté pour le numéro ${signalement.numero}');
    } catch (e) {
      print('Erreur lors de l\'ajout du signalement : $e');
      rethrow;
    }
  }

  /// Retourne le nombre de signalements pour un numéro donné
  int nombreSignalements(String numero) {
    return _signalementsParNumero[numero]?.length ?? 0;
  }

  /// Retourne la liste des signalements pour un numéro donné
  List<Signalement> getSignalements(String numero) {
    return _signalementsParNumero[numero] ?? [];
  }
}

class ThemeProvider with ChangeNotifier {
  // Par défaut, le thème est clair
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  // Fonction pour changer le thème
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners(); // Notifie les auditeurs que l'état a changé
  }
}

class UsersProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _limit = 20;

  List<Map<String, dynamic>> get users => _users;

  bool get isLoading => _isLoading;

  bool get hasMore => _hasMore;

  Future<void> loadUsers() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    // Removed initial notifyListeners()

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .order('created_at', ascending: false)
        .range(_page * _limit, (_page + 1) * _limit - 1);

    if (response.isEmpty) {
      _hasMore = false;
    } else {
      _users.addAll(List<Map<String, dynamic>>.from(response));
      _page++;
    }

    _isLoading = false;
    notifyListeners(); // Keep this notifyListeners()
  }

  Future<void> deleteUser(String id) async {
    await Supabase.instance.client.from('users').delete().eq('id', id);
    _users.removeWhere((user) => user['id'] == id);
    notifyListeners();
  }

  void reset() {
    _users.clear();
    _page = 0;
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<int> getSignalementsCount(String userId) async {
    try {
      print(userId);

      final response = await Supabase.instance.client
          .from('signalements')
          .select('id')
          .eq('user', userId);

      return (response as List).length;
    } catch (e) {
      print('Error getting signalements count: $e');
      return 0;
    }
  }
}

class LocalizationModel with ChangeNotifier {
  Locale _locale = Locale('fr'); // Valeur par défaut
  final List<String> supportedLanguages = [
    'en',
    'fr',
    'ar',
    'es',
    'zh',
    'ja',
    'th',
    'ru',
    'it',
  ];

  Locale get locale => _locale;

  // Initialise la locale avec celle du système ou celle sauvegardée
  Future<void> initLocale() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Vérifier si une langue est déjà sauvegardée
      String? savedLanguage = prefs.getString('language_code');

      if (savedLanguage != null && supportedLanguages.contains(savedLanguage)) {
        // Utiliser la langue sauvegardée si elle est supportée
        _locale = Locale(savedLanguage);
      } else {
        // Utiliser la langue du système si elle est supportée
        final String deviceLocale =
            WidgetsBinding.instance.platformDispatcher.locale.languageCode;

        // Vérifier si la langue du système est supportée
        if (supportedLanguages.contains(deviceLocale)) {
          _locale = Locale(deviceLocale);
        } else {
          // Langue par défaut si celle du système n'est pas supportée
          _locale = Locale('fr');
        }

        // Sauvegarder la locale détectée ou par défaut
        await prefs.setString('language_code', _locale.languageCode);
      }

      notifyListeners();
    } catch (e) {
      print("Erreur lors de l'initialisation de la locale: $e");
      // En cas d'erreur, on garde la locale par défaut
      _locale = Locale('fr');
    }
  }

  // Changer la langue et la sauvegarder
  Future<void> changeLocale(String languageCode) async {
    try {
      if (!supportedLanguages.contains(languageCode)) {
        throw Exception('Langue non supportée: $languageCode');
      }

      _locale = Locale(languageCode);

      // Sauvegarder la langue dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);

      notifyListeners();
    } catch (e) {
      print("Erreur lors du changement de locale: $e");
      rethrow; // Permet à l'UI de gérer l'erreur si nécessaire
    }
  }
}
