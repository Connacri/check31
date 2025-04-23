import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../checkit/HomePage.dart';
import '../checkit/provider.dart';
import '../checkit/providerF.dart';

import 'package:flutter/foundation.dart';

const int maxFailedLoadAttempts = 3;

class MyApp9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignalementProvider()),
        ChangeNotifierProvider(create: (_) => SignalementProviderSupabase()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'POS',
            theme: ThemeData(
              fontFamily: 'oswald',
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey[300]!,
                labelStyle: TextStyle(fontFamily: 'oswald'),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
                // Texte par défaut en noir
                bodyLarge: TextStyle(color: Colors.black),
                // Texte plus grand en noir
                bodySmall: TextStyle(color: Colors.black),
                // Texte plus petit en noir
                titleMedium: TextStyle(color: Colors.black),
                // Titres en noir
                titleLarge: TextStyle(color: Colors.black),
                // Titres plus grands en noir
                labelLarge: TextStyle(color: Colors.black), // Labels en noir
              ),
            ),

            darkTheme: ThemeData(
              fontFamily: 'oswald',
              brightness: Brightness.dark,
              primaryColor: Colors.blueGrey,
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey[800]!,
                labelStyle: TextStyle(fontFamily: 'oswald'),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
                // Texte en blanc pour le mode sombre
                bodyLarge: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.white),
                labelLarge: TextStyle(color: Colors.white),
              ),
            ),
            themeMode:
                themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: HomePage3(),
          );
        },
      ),
    );
  }
}
