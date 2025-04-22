// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:lottie/lottie.dart';
//
// class LottieListPage extends StatefulWidget {
//   @override
//   _LottieListPageState createState() => _LottieListPageState();
// }
//
// class _LottieListPageState extends State<LottieListPage> {
//   List<String> lottieFileNames = []; // List of Lottie file names
//
//   @override
//   void initState() {
//     super.initState();
//     loadLottieFiles();
//   }
//
//   // Load the list of Lottie files from the assets folder
//   Future<void> loadLottieFiles() async {
//     try {
//       final manifestContent = await rootBundle.loadString('AssetManifest.json');
//       final Map<String, dynamic> manifestMap = json.decode(manifestContent);
//       final lottieFiles = manifestMap.keys
//           .where((String key) => key.contains('assets/lotties/'))
//           .toList();
//
//       setState(() {
//         lottieFileNames = lottieFiles;
//       });
//     } catch (e) {
//       print('Error loading Lottie files: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('List of Lottie Animations'),
//       ),
//       body: GridView.builder(
//         itemCount: lottieFileNames.length,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: MediaQuery.of(context).size.width < 600
//               ? 2 // Si la largeur est inférieure à 600, 2 colonnes
//               : (Platform.isAndroid || Platform.isIOS)
//                   ? 2 // Pour Android/iOS, 2 colonnes
//                   : 6, // Pour les autres plateformes, 6 colonnes          childAspectRatio: 1.0, // Proportion largeur/hauteur des éléments
//         ),
//         itemBuilder: (context, index) {
//           final lottieFileName = lottieFileNames[index];
//           final lottieFilePath = '$lottieFileName';
//
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Card(
//               elevation: 2.0,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     lottieFileName,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//
//                   FittedBox(
//                     child: Lottie.asset(
//                       '$lottieFilePath',
//                     ),
//                   ), // Chemin du fichier Lottie
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
