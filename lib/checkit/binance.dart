import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BinancePage extends StatefulWidget {
  @override
  State<BinancePage> createState() => _BinancePageState();
}

class _BinancePageState extends State<BinancePage> {
  final supabase = Supabase.instance.client;

  String binanceUrl = '';
  String prix = '';
  bool isLoading = true;
  String? binanceId; // ID UUID réel pour update

  @override
  void initState() {
    super.initState();
    fetchBinanceData();
  }

  Future<void> fetchBinanceData() async {
    try {
      final data =
          await supabase
              .from('binance')
              .select()
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (data != null) {
        setState(() {
          binanceId = data['id'];
          binanceUrl = data['url'] ?? '';
          prix = data['prix']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Aucune entrée Binance trouvée');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Erreur Supabase : $e');
    }
  }

  Future<void> openBinanceUrl() async {
    if (binanceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lien Binance non disponible.")),
      );
      return;
    }

    final uri = Uri.tryParse(binanceUrl);
    if (uri == null || !uri.isAbsolute) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lien Binance invalide.")));
      return;
    }

    showLoader();

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le lien Binance.")),
        );
      }
    } catch (e) {
      debugPrint("Erreur ouverture lien : $e");
    } finally {
      Navigator.pop(context); // Fermer loader
    }
  }

  void showLoader() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(child: LinearProgressIndicator()),
    );
  }

  Future<void> askPasswordAndEdit() async {
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Authentification admin"),
            content: TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              TextButton(
                child: const Text("Continuer"),
                onPressed: () {
                  if (passwordCtrl.text == '123456') {
                    Navigator.pop(context);
                    showEditDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mot de passe incorrect.")),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> showEditDialog() async {
    final urlCtrl = TextEditingController(text: binanceUrl);
    final prixCtrl = TextEditingController(text: prix);

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Modifier le lien Binance"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: "Lien Binance"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: prixCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Montant (€)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  editBinanceData(urlCtrl.text.trim(), prixCtrl.text.trim());
                },
                child: const Text("Enregistrer"),
              ),
            ],
          ),
    );
  }

  Future<void> editBinanceData(String newUrl, String newPrix) async {
    if (newUrl.isEmpty || newPrix.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lien et montant obligatoires.")),
      );
      return;
    }

    final parsedPrix = double.tryParse(newPrix.replaceAll(',', '.'));
    if (parsedPrix == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Montant invalide.")));
      return;
    }

    showLoader();

    try {
      Map<String, dynamic> data = {'url': newUrl, 'prix': parsedPrix};

      if (binanceId != null) {
        // Mise à jour
        await supabase.from('binance').update(data).eq('id', binanceId!);
      } else {
        // Création
        final inserted =
            await supabase.from('binance').insert(data).select().single();
        binanceId = inserted['id'];
      }

      setState(() {
        binanceUrl = newUrl;
        prix = parsedPrix.toStringAsFixed(2);
      });

      Navigator.pop(context); // Ferme loader

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Données enregistrées.")));
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Erreur Supabase : $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erreur de sauvegarde.")));
    }
  }

  Widget buildDonationSection() {
    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.center,
        //  crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // Coins arrondis
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage('assets/logos/binancelogo.png'),
                height: 200,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: openBinanceUrl, // action comme un bouton
                  splashColor: Colors.orange.withOpacity(0.3),
                ),
              ),
            ),
          ),

          const Positioned(
            top: 15,
            child: Text(
              "Aidez-moi à améliorer l'application !\nUn simple café peut faire la différence ☕",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xfff4c71d)),
            ),
          ),
          const SizedBox(height: 16),
          Positioned(
            bottom: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.coffee, color: Colors.black54, size: 20),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pay me a coffee",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (prix.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Text(
                        "$prix €",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
                onPressed: openBinanceUrl,
                style: ElevatedButton.styleFrom(
                  // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  backgroundColor: Color(0xfff4c71d),
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
    //Scaffold(
    // appBar: AppBar(
    //   title: const Text("Paiement Binance"),
    //   actions: [
    //     IconButton(
    //       icon: const Icon(Icons.admin_panel_settings),
    //       tooltip: "Modifier lien (admin)",
    //       onPressed: askPasswordAndEdit,
    //     ),
    //   ],
    // ),
    //body:
    isLoading
        ? const Center(child: LinearProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildDonationSection(),
          // ),
        );
  }
}

class BinancePage2 extends StatefulWidget {
  @override
  State<BinancePage2> createState() => _BinancePage2State();
}

class _BinancePage2State extends State<BinancePage2> {
  final supabase = Supabase.instance.client;

  String binanceUrl = '';
  String prix = '';
  bool isLoading = true;
  String? binanceId; // ID UUID réel pour update

  @override
  void initState() {
    super.initState();
    fetchBinanceData();
  }

  Future<void> fetchBinanceData() async {
    try {
      final data =
          await supabase
              .from('binance')
              .select()
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (data != null) {
        setState(() {
          binanceId = data['id'];
          binanceUrl = data['url'] ?? '';
          prix = data['prix']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Aucune entrée Binance trouvée');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Erreur Supabase : $e');
    }
  }

  Future<void> openBinanceUrl() async {
    if (binanceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lien Binance non disponible.")),
      );
      return;
    }

    final uri = Uri.tryParse(binanceUrl);
    if (uri == null || !uri.isAbsolute) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lien Binance invalide.")));
      return;
    }

    showLoader();

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le lien Binance.")),
        );
      }
    } catch (e) {
      debugPrint("Erreur ouverture lien : $e");
    } finally {
      Navigator.pop(context); // Fermer loader
    }
  }

  void showLoader() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(child: LinearProgressIndicator()),
    );
  }

  Future<void> askPasswordAndEdit() async {
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Authentification admin"),
            content: TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              TextButton(
                child: const Text("Continuer"),
                onPressed: () {
                  if (passwordCtrl.text == '123456') {
                    Navigator.pop(context);
                    showEditDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mot de passe incorrect.")),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> showEditDialog() async {
    final urlCtrl = TextEditingController(text: binanceUrl);
    final prixCtrl = TextEditingController(text: prix);

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Modifier le lien Binance"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: "Lien Binance"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: prixCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Montant (€)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  editBinanceData(urlCtrl.text.trim(), prixCtrl.text.trim());
                },
                child: const Text("Enregistrer"),
              ),
            ],
          ),
    );
  }

  Future<void> editBinanceData(String newUrl, String newPrix) async {
    if (newUrl.isEmpty || newPrix.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lien et montant obligatoires.")),
      );
      return;
    }

    final parsedPrix = double.tryParse(newPrix.replaceAll(',', '.'));
    if (parsedPrix == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Montant invalide.")));
      return;
    }

    showLoader();

    try {
      Map<String, dynamic> data = {'url': newUrl, 'prix': parsedPrix};

      if (binanceId != null) {
        // Mise à jour
        await supabase.from('binance').update(data).eq('id', binanceId!);
      } else {
        // Création
        final inserted =
            await supabase.from('binance').insert(data).select().single();
        binanceId = inserted['id'];
      }

      setState(() {
        binanceUrl = newUrl;
        prix = parsedPrix.toStringAsFixed(2);
      });

      Navigator.pop(context); // Ferme loader

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Données enregistrées.")));
    } catch (e) {
      Navigator.pop(context);
      debugPrint("Erreur Supabase : $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erreur de sauvegarde.")));
    }
  }

  Widget buildDonationSection() {
    return SingleChildScrollView(
      child: Column(
        //alignment: Alignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // Coins arrondis
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage('assets/logos/binancelogo.png'),
                height: 200,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: openBinanceUrl, // action comme un bouton
                  splashColor: Colors.orange.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Aidez-moi à améliorer l'application !\nUn simple café peut faire la différence ☕",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.coffee, color: Colors.black54, size: 20),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Pay me a coffee",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (prix.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    "$prix €",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
            onPressed: openBinanceUrl,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              backgroundColor: Color(0xfff4c71d),
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Binance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: "Modifier lien (admin)",
            onPressed: askPasswordAndEdit,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: LinearProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildDonationSection(),
              ),
    );
  }
}
