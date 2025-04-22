import 'package:flutter/material.dart';
import '../checkit/provider.dart';
import 'package:provider/provider.dart';

import 'Models.dart';

/// Interface principale avec formulaire d'ajout et recherche
class SignalHomePage_Firebase extends StatefulWidget {
  @override
  State<SignalHomePage_Firebase> createState() =>
      _SignalHomePage_FirebaseState();
}

class _SignalHomePage_FirebaseState extends State<SignalHomePage_Firebase> {
  final numeroController = TextEditingController();
  final utilisateurController = TextEditingController();
  final descriptionController = TextEditingController();
  final motifController = TextEditingController();
  final graviteController = TextEditingController();

  String? numeroRecherche;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignalementProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Numéros signalés')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: numeroController,
              decoration: InputDecoration(labelText: 'Numéro'),
            ),
            TextField(
              controller: utilisateurController,
              decoration: InputDecoration(labelText: 'Nom du signaleur'),
            ),
            TextField(
              controller: motifController,
              decoration: InputDecoration(labelText: 'Motif'),
            ),
            TextField(
              controller: graviteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Gravité (1-5)'),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  InputDecoration(labelText: 'Description (optionnelle)'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final signalement = Signalement(
                      numero: numeroController.text.trim(),
                      signalePar: utilisateurController.text.trim(),
                      motif: motifController.text.trim(),
                      gravite: int.tryParse(graviteController.text.trim()) ?? 1,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      date: DateTime.now(),
                      user: '',
                    );
                    await provider.ajouterSignalement(signalement);
                    numeroController.clear();
                    utilisateurController.clear();
                    motifController.clear();
                    graviteController.clear();
                    descriptionController.clear();
                  },
                  child: Text("Ajouter"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numeroRecherche = numeroController.text.trim();
                    });
                  },
                  child: Text("Rechercher"),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (numeroRecherche != null) ...[
              Text(
                "Signalements pour $numeroRecherche : ${provider.nombreSignalements(numeroRecherche!)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: provider.getSignalements(numeroRecherche!).map((s) {
                    return ListTile(
                      title: Text("${s.signalePar} - Gravité: ${s.gravite}"),
                      subtitle: Text(s.description ?? 'Aucune description'),
                      trailing: Text(
                        '${s.date.day}/${s.date.month}/${s.date.year}',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
