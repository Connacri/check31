import 'package:flutter/foundation.dart';
import '../checkit/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Models.dart';

class SignalementProviderSupabase with ChangeNotifier {
  final _client = Supabase.instance.client;

  final Map<String, List<Signalement>> _signalementsParNumero = {};

  Map<String, List<Signalement>> get signalementsParNumero =>
      _signalementsParNumero;

  String? normalizeAndValidateAlgerianPhone(String numero) {
    // Supprimer les espaces
    String num = numero.toString().replaceAll(RegExp(r'\s+'), '');
    // Enlever préfixe 213
    if (num.startsWith('213')) {
      num = num.substring(3);
    }
    // Enlever préfixe +213
    if (num.startsWith('+213')) {
      num = num.substring(4);
    }
    // Enlever préfixe 00213
    else if (num.startsWith('00213')) {
      num = num.substring(5);
    }
    // Enlever 0 initial
    else if (num.startsWith('0')) {
      num = num.substring(1);
    }

    // Vérifier que c’est bien un numéro algérien à 9 chiffres commençant par 5, 6 ou 7
    if (RegExp(r'^[5-7][0-9]{8}$').hasMatch(num)) {
      return num;
    }

    return null; // Numéro invalide
  }

  Future<void> chargerSignalements(String userID) async {
    final response = await _client
        .from('signalements')
        .select()
        .eq('signalePar', userID)
        .order('date', ascending: false);

    final data = response as List;
    _signalementsParNumero.clear();

    for (final item in data) {
      final s = Signalement.fromJson(item);

      // Normalisation du numéro
      String? numero = normalizeAndValidateAlgerianPhone(s.numero.toString());

      // Utilise le numéro normalisé comme clé
      _signalementsParNumero.putIfAbsent(numero.toString(), () => []).add(s);
    }

    notifyListeners();
  }

  /// Retourne l’opérateur à partir du numéro
  String detecterOperateur(String numero) {
    if (numero.startsWith('05') || numero.startsWith('5')) {
      return 'Ooredoo';
    } else if (numero.startsWith('06') || numero.startsWith('6')) {
      return 'Mobilis';
    } else if (numero.startsWith('07') || numero.startsWith('7')) {
      return 'Djezzy';
    } else {
      return 'Inconnu';
    }
  }

  /// Retourne le chemin du logo de l’opérateur
  String getLogoOperateur(String operateur) {
    switch (operateur) {
      case 'Ooredoo':
        return 'assets/logos/ooredoo.png';
      case 'Mobilis':
        return 'assets/logos/mobilis.png';
      case 'Djezzy':
        return 'assets/logos/djezzy.png';
      default:
        return 'assets/logos/inconnu.png';
    }
  }

  Future<void> ajouterSignalement(
      Signalement signalement, String userID) async {
    await _client.from('signalements').insert(signalement.toJson());
    await chargerSignalements(userID); // recharge après ajout
  }

  Future<int> nombreSignalements(String numero) async {
    final response =
        await _client.from('signalements').select().eq('numero', numero);

    return (response as List).length;
  }

  List<Signalement> getSignalements(String numero) {
    return _signalementsParNumero[numero] ?? [];
  }

  bool isValidAlgerianPhoneNumber(String phoneNumber) {
    // Supprimer les espaces
    String num = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // Vérifier les formats valides
    return RegExp(r'^(\+213|213|00213|0)?(5|6|7)\d{8}$').hasMatch(num);
  }

  // Future<bool> checkIfAlreadyReported(String numero, String userId) async {
  //   try {
  //     final response = await _client
  //         .from('signalements')
  //         .select('id')
  //         .eq('numero', numero)
  //         .eq('signalePar',
  //             userId) // Utilisation du nom exact de colonne avec guillemets
  //         .limit(1)
  //         .maybeSingle(); // Utilise maybeSingle() au lieu de vérifier isEmpty
  //     print(numero);
  //     print(userId);
  //     print(response);
  //     return response != null;
  //   } catch (e) {
  //     print('Erreur vérification signalement: $e');
  //     return false;
  //   }
  // }
  Future<bool> checkIfAlreadyReported(String numero, String userId) async {
    final response = await _client
        .from('signalements')
        .select('id')
        .eq('numero', numero) // Vérifie si le numéro existe
        .eq('user', userId) // Vérifie si l'utilisateur l'a déjà signalé
        .limit(
            1); // Limite à 1 résultat (même si plusieurs existent, on prend le premier)

    return response
        .isNotEmpty; // Si la liste n'est pas vide, cela signifie qu'il existe un signalement
  }
}
