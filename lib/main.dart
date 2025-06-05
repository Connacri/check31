import 'dart:async';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importez cette ligne
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as su;
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'checkit/MyApp.dart';
import 'checkit/provider.dart';
import 'checkit/providerF.dart';

Future<void> main() async {
  // Initialisation de Flutter
  //WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //await FlutterLocalization.instance.ensureInitialized();
  // Initialiser la langue avant de lancer l'application

  final localizationModel = LocalizationModel();
  await localizationModel.initLocale();
  // MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Initialisation de Supabase (si async)
  await initializeSupabase();

  //await Firebase.initializeApp(name: projectId, demoProjectId: projectId);
  // Initialisation de Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Configuration de Firestore (cache local activé)
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  // );

  initializeDateFormatting(
    'fr_FR',
    null,
  ); // Initialisez la localisation française
  if (Platform.isAndroid || Platform.isIOS) {
    MobileAds.instance.initialize();
  } else {
    print("Google Mobile Ads n'est pas supporté sur cette plateforme");
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
  runApp(MyApp9());
}

Future<void> initializeSupabase() async {
  const supabaseUrl = 'https://zjbnzghyhdhlivpokstz.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqYm56Z2h5aGRobGl2cG9rc3R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg2ODA1MjcsImV4cCI6MjA1NDI1NjUyN30.99PBeSXyoFJQMFopizHfLDlqLrMunSBLlBfTGcLIpv8';

  try {
    // await su.Supabase.initialize(
    //   url: supabaseUrl,
    //   anonKey: supabaseKey,
    //   //debug: true,
    // );
    await su.Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      authOptions: const su.FlutterAuthClientOptions(
        authFlowType: su.AuthFlowType.pkce,
      ),
      realtimeClientOptions: const su.RealtimeClientOptions(
        logLevel: su.RealtimeLogLevel.info,
      ),
      storageOptions: const su.StorageClientOptions(retryAttempts: 10),
    );
    if (su.Supabase.instance == null) {
      print('Supabase initialization failed.');
      return;
    }

    print('Supabase initialized successfully.');
  } catch (error) {
    //  print('Error initializing Supabase: $error');
  }
}

// Future initialization(BuildContext? context) async {
//   Future.delayed(Duration(seconds: 5));
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Message reçu en arrière-plan : ${message.messageId}");
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({
    super.key,
    /*required this.objectBox*/
  });

  //  final ObjectBox objectBox;
  //   static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  //   static FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  static const String _title = 'DZ Wallet';

  @override
  State<MyApp> createState() => _MyAppState();
}

final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class _MyAppState extends State<MyApp> {
  bool _isLicenseValidated = false;
  bool _isLicenseDemoValidated = false;

  //final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // initializeDefault();
    _checkLicenseStatus();
  }

  Future<void> _checkLicenseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifier les deux états dans SharedPreferences
    bool? isLicenseValidated = prefs.getBool('isLicenseValidated');
    bool? isLicenseDemoValidated = prefs.getBool('isLicenseDemoValidated');

    // Mettre à jour l'état en fonction des valeurs récupérées
    if (isLicenseValidated != null && isLicenseValidated) {
      setState(() {
        _isLicenseValidated = true;
      });
    } else if (isLicenseDemoValidated != null && isLicenseDemoValidated) {
      setState(() {
        _isLicenseDemoValidated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: globalScaffoldMessengerKey,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'OSWALD',
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.black87)),
      ),
      locale: const Locale('fr', 'CA'),

      //scaffoldMessengerKey: Utils.messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Ramzi',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),
      home:
          //testhome()
          MyApp9(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MyApp9 extends StatelessWidget {
  const MyApp9({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignalementProvider()),
        ChangeNotifierProvider(create: (_) => SignalementProviderSupabase()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (context) => LocalizationModel()),
      ],
      child: MyApp99(),
    );
  }
}
