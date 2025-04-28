import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../AppLocalizations.dart';
import '../checkit/HomePage.dart';
import '../checkit/provider.dart';
import '../checkit/providerF.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const int maxFailedLoadAttempts = 3;

class MyApp99 extends StatefulWidget {
  @override
  State<MyApp99> createState() => _MyApp99State();
}

class _MyApp99State extends State<MyApp99> {
  @override
  void initState() {
    super.initState();
    // Initialise la locale au démarrage
    Future.delayed(Duration.zero, () {
      Provider.of<LocalizationModel>(context, listen: false).initLocale();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocalizationModel>(
      builder: (context, themeProvider, localizationModel, child) {
        String fontAr = 'KHALED';
        return BetterFeedback(
          localeOverride: localizationModel.locale,
          child: MaterialApp(
            title: 'Check-it',
            locale: localizationModel.locale,
            // Utilisation de la locale du provider
            supportedLocales: [
              Locale('en'),
              Locale('fr'),
              Locale('ar'),
              Locale('es'),
              Locale('zh'),
              Locale('ja'),
              Locale('it'),
              Locale('ru'),
              Locale('th'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily:
                  localizationModel.locale.languageCode == 'ar'
                      ? fontAr
                      : 'oswald',
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey[300]!,
                labelStyle: TextStyle(
                  fontFamily:
                      localizationModel.locale.languageCode == 'ar'
                          ? fontAr
                          : 'oswald',
                ),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
                bodyLarge: TextStyle(color: Colors.black),
                bodySmall: TextStyle(color: Colors.black),
                titleMedium: TextStyle(color: Colors.black),
                titleLarge: TextStyle(color: Colors.black),
                labelLarge: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              fontFamily:
                  localizationModel.locale.languageCode == 'ar'
                      ? fontAr
                      : 'oswald',
              brightness: Brightness.dark,
              primaryColor: Colors.blueGrey,
              chipTheme: ChipThemeData(
                backgroundColor: Colors.grey[800]!,
                labelStyle: TextStyle(
                  fontFamily:
                      localizationModel.locale.languageCode == 'ar'
                          ? fontAr
                          : 'oswald',
                ),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
                bodyLarge: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                titleLarge: TextStyle(color: Colors.white),
                labelLarge: TextStyle(color: Colors.white),
              ),
            ),
            themeMode:
                themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              // appBar: AppBar(
              //   centerTitle: true,
              //   title: ClipRRect(
              //     borderRadius: BorderRadius.circular(12.0),
              //     // Adjust the radius as needed
              //     child: Image.asset(
              //       'assets/images/banner.png',
              //       height: 50,
              //       width: 100,
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              body: HomePage3(),
            ),
          ),
        );
      },
    );
  }
}
