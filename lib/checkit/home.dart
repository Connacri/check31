import 'package:flutter/material.dart';
import '../AppLocalizations.dart';
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
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).translate('reportedNumbers')}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: numeroController,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('number')}',
              ),
            ),
            TextField(
              controller: utilisateurController,
              decoration: InputDecoration(labelText: 'Nom du signaleur'),
            ),
            TextField(
              controller: motifController,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('reason')}',
              ),
            ),
            TextField(
              controller: graviteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('severity')}',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText:
                    '${AppLocalizations.of(context).translate('descriptionOptional')}',
              ),
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
                      description:
                          descriptionController.text.trim().isEmpty
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
                  child: Text(
                    '${AppLocalizations.of(context).translate('add')}',
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numeroRecherche = numeroController.text.trim();
                    });
                  },
                  child: Text(
                    '${AppLocalizations.of(context).translate('search')}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (numeroRecherche != null) ...[
              Text(
                "${AppLocalizations.of(context).translate('reportsFor')} $numeroRecherche : ${provider.nombreSignalements(numeroRecherche!)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children:
                      provider.getSignalements(numeroRecherche!).map((s) {
                        return ListTile(
                          title: Text(
                            "${s.signalePar} - ${AppLocalizations.of(context).translate('severityOnly')} : ${s.gravite}",
                          ),
                          subtitle: Text(
                            s.description ??
                                '${AppLocalizations.of(context).translate('noDescription')} ',
                          ),
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
