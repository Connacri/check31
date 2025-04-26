import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:check31/checkit/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AppLocalizations.dart';
import 'users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../My_widgets.dart';
import '../checkit/admobHelper.dart';
import '../checkit/providerF.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as su;
import 'package:timeago/timeago.dart' as timeago;
import '../MyListLotties.dart';
import 'AuthProvider.dart';
import 'EnhancedCallScreen.dart';
import 'Models.dart';
import 'admob/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class HomePage3 extends StatefulWidget {
  @override
  _HomePage3State createState() => _HomePage3State();
}

class _HomePage3State extends State<HomePage3> {
  final AuthService _authService = AuthService();
  User? _user;
  final numeroController = TextEditingController();
  final motifController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showDetail = true;
  bool _showSignalBtn = true;
  String? numeroRecherche;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd1;
  InterstitialAd? _interstitialAd2;

  bool _isAd1Ready = false;
  bool _isAd2Ready = false;
  String adUnitId1 = 'ca-app-pub-2282149611905342/7655852483';
  String adUnitId2 = 'ca-app-pub-2282149611905342/7243723285';

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'achat',
      'promo',
      'remise',
      'shopping',
      'soldes',
      'market dz',
      'prix',
      'commande en ligne',
      'baridi mob',
      'edahabia',
      'cib',
      'application bancaire',
      'crypto dz',
      'pret algerie',
      'investissement',
      'voiture',
      'leasing algerie',
      'location voiture',
      'auto occasion',
      'marché de l’auto',
      'assurance auto',
      'voiture',
      'leasing algerie',
      'location voiture',
      'auto occasion',
      'marché de l’auto',
      'assurance auto',
      'mobilis',
      'djezzy',
      'oota',
      'forfait internet',
      'recharge',
      'appels pas chers',
      'internet algerie',
      'louer appartement',
      'vente maison',
      'immobilier algerie',
      'terrain à vendre',
      'location studio',
      'b2b algerie',
      'grossiste',
      'fournisseur',
      'marché de gros',
      'logiciel de caisse',
      'gestion stock',
    ],
    contentUrl: 'walletdz-d12e0.web.app',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // RewardedAd? _rewardedAd;
  // int _numRewardedLoadAttempts = 0;
  //
  // RewardedInterstitialAd? _rewardedInterstitialAd;
  // int _numRewardedInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsersAsync();
    });
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
    _user != null
        ? WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<SignalementProviderSupabase>(
            context,
            listen: false,
          ).chargerSignalements(_user!.uid);
        })
        : null;
    if (Platform.isAndroid)
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failure to load _adBanner ${err.message}');
            ad.dispose();
          },
        ),
      )..load();

    _initializeFCM();
    numeroController.addListener(_handleTextChange);
    _loadBannerAd();
    _loadInterstitialAd1();
    _loadInterstitialAd2();
  }

  Future<void> _loadUsersAsync() async {
    final provider = Provider.of<UsersProvider>(context, listen: false);
    await provider.loadUsers();
  }

  Future<void> _loadBannerAd() async {
    if (!Platform.isAndroid) return;

    await BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: request,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Erreur bannière: ${err.message}');
          ad.dispose();
          _isBannerAdReady = false;
        },
      ),
    ).load();
  }

  void _loadInterstitialAd1() {
    InterstitialAd.load(
      adUnitId: adUnitId1,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd1 = ad;
          _isInterstitialAdReady = true; // La publicité est prête
          setState(() {
            _isAd1Ready = true;
          });
          print('Ad 1 is ready');
        },
        onAdFailedToLoad: (error) {
          print('Ad 1 failed to load: $error');
          _isInterstitialAdReady = false; // Échec du chargement
          setState(() {
            _isAd1Ready = false;
          });
        },
      ),
    );
  }

  void _loadInterstitialAd2() {
    InterstitialAd.load(
      adUnitId: adUnitId2,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd2 = ad;
          _isInterstitialAdReady = true; // La publicité est prête
          setState(() {
            _isAd2Ready = true;
          });
          print('Ad 2 is ready');
        },
        onAdFailedToLoad: (error) {
          print('Ad 2 failed to load: $error');
          _isInterstitialAdReady = false; // Échec du chargement
          setState(() {
            _isAd2Ready = false;
          });
        },
      ),
    );
  }

  void _showReadyInterstitialAd({VoidCallback? onAdClosed}) {
    if (_isAd1Ready && _interstitialAd1 != null) {
      _interstitialAd1!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Ad 1 dismissed.');
          ad.dispose();
          _loadInterstitialAd1(); // Recharge l'ad
          if (onAdClosed != null) {
            onAdClosed(); // même si la pub échoue, on continue
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Ad 1 failed to show: $error');
          ad.dispose();
          _loadInterstitialAd1(); // Recharge l'ad
          if (onAdClosed != null) {
            onAdClosed(); // même si la pub échoue, on continue
          }
        },
      );
      _interstitialAd1!.show();
      _interstitialAd1 = null; // Réinitialiser après affichage
    } else if (_isAd2Ready && _interstitialAd2 != null) {
      _interstitialAd2!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Ad 2 dismissed.');
          ad.dispose();
          _loadInterstitialAd2(); // Recharge l'ad
          if (onAdClosed != null) {
            onAdClosed(); // même si la pub échoue, on continue
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Ad 2 failed to show: $error');
          ad.dispose();
          _loadInterstitialAd2(); // Recharge l'ad
          if (onAdClosed != null) {
            onAdClosed(); // même si la pub échoue, on continue
          }
        },
      );
      _interstitialAd2!.show();
      _interstitialAd2 = null; // Réinitialiser après affichage
    } else {
      print('Aucune interstitial prête');
    }
  }

  void _handleTextChange() {
    if (numeroController.text.isEmpty) {
      setState(() {
        _showSignalBtn = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    numeroController.removeListener(_handleTextChange);
    _interstitialAd?.dispose();
    //_rewardedAd?.dispose();
    _bannerAd?.dispose();
    _interstitialAd1?.dispose();
    _interstitialAd2?.dispose();
    // _rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  void _initializeFCM() async {
    await _messaging.requestPermission();
    await _messaging.subscribeToTopic('checkit_alerts');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu : ${message.notification?.title}');
      // Gère le message reçu
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print('Message en arrière-plan : ${message.messageId}');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Center(
              child: Text(
                AppLocalizations.of(context).translate('error'),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.all(18.0),
              child: FittedBox(
                child: Text(message, textAlign: TextAlign.center),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  String selectedMotif = 'motifFraud'; // Utiliser la clé ici

  final List<String> motifs = [
    'motifFraud',
    'motifAbusiveBehavior',
    'motifExcessiveReturns',
    'motifNonPayment',
    'motifViolationTerms',
    'motifShoplifting',
    'motifFalseClaim',
    'motifMisusePromotions',
    'motifSuspiciousBehavior',
    'motifNonComplianceSafetyRules',
    'motifRefusalReceipt',
    'motifLatePayment',
    'motifFraudulentPaymentMethods',
    'motifBadFaithClaim',
    'motifNonComplianceDelivery',
    'motifReturnAbuse',
    'motifUnjustifiedRefundRequest',
    'motifUseFalsifiedDocuments',
    'motifNonDeliveryToCorrectPerson',
    'motifFraudAttemptProducts',
    'motifFrequentOrderChanges',
    'motifThreateningBehavior',
    'motifSafetyInstructionsIgnorance',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignalementProviderSupabase>(context);
    String imageUrl = 'https://picsum.photos/200/300';
    return Scaffold(
      resizeToAvoidBottomInset: true, // important !
      appBar: AppBar(
        leading:
            _user?.displayName != null
                ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      // Vérifiez si une publicité interstitielle est prête
                      if (_isInterstitialAdReady) {
                        _showReadyInterstitialAd(
                          onAdClosed: () {
                            // Redirection après la fermeture de la publicité
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => googleBtn()),
                            );
                          },
                        );
                      } else {
                        // Si aucune publicité n'est prête, redirigez directement
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => googleBtn()),
                        );
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                      radius: 15, // Important : plus petit pour AppBar
                    ),
                  ),
                )
                : IconButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => googleBtn())),
                  icon: Icon(Icons.account_circle, size: 35),
                ),
        title: Text(
          _user != null
              ? '${_user!.displayName ?? AppLocalizations.of(context).translate('user')}'
              : AppLocalizations.of(context).translate('unknownUser'),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          LanguageDropdownFlag(),
          _user == null
              ? SizedBox.shrink()
              : IconButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => EnhancedCallScreen()),
                    ),
                icon: Icon(
                  Icons.phone,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
          // _user == null || _user!.email != 'forslog@gmail.com'
          //     ? SizedBox.shrink()
          //     : IconButton.outlined(
          //         onPressed: () => Navigator.of(context).push(
          //             MaterialPageRoute(builder: (ctx) => LottieListPage())),
          //         icon: Icon(Icons.animation)),
          // _user == null || _user!.email != 'forslog@gmail.com'
          //     ? SizedBox.shrink()
          //     : IconButton.outlined(
          //       onPressed:
          //           () => Navigator.of(
          //             context,
          //           ).push(MaterialPageRoute(builder: (ctx) => UsersPage())),
          //       icon: Icon(
          //         Icons.supervised_user_circle_sharp,
          //         color: Colors.blue,
          //       ),
          //     ),
          // if (_user != null)
          //   IconButton(
          //     icon: Icon(Icons.logout),
          //     onPressed: _handleSignOut,
          //   ),
          SizedBox(width: 5),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: //const EdgeInsets.all(8.0),
              EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            top: 0,
          ),
          child: IntrinsicHeight(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // FittedBox(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //
                  //     children: const [
                  //       Text(
                  //         'Check',
                  //         style: TextStyle(
                  //           fontSize: 25,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       Text(
                  //         '.',
                  //         style: TextStyle(
                  //           fontSize: 25,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.red,
                  //           textBaseline: TextBaseline.alphabetic,
                  //         ),
                  //       ),
                  //
                  //       Text(
                  //         'it',
                  //         style: TextStyle(
                  //           fontSize: 25,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.red,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  _user != null && _user!.email == 'forslog@gmail.com'
                      ? Consumer<UsersProvider>(
                        builder:
                            (context, provider, _) => Card(
                              color: Colors.deepPurple,
                              child: ListTile(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => UsersPage(),
                                      ),
                                    ),
                                leading: CircleAvatar(
                                  child: Text(
                                    '${provider.users.length}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                title: Text(
                                  'Utilisateurs',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      )
                      : SizedBox.shrink(),
                  SizedBox(height: 10),

                  // Center(
                  //   child: Text(
                  //     AppLocalizations.of(context).translate('hello'),
                  //     style: TextStyle(fontSize: 24),
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: animatedWords,
                    repeatForever: true,
                    pause: Duration(milliseconds: 1000),
                    isRepeatingAnimation: true,
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: InkWell(
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          useRootNavigator: false,
                          routeSettings: RouteSettings(),
                          applicationIcon: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            // Coins arrondis
                            child: Image.asset(
                              'assets/icon/icon.png',
                              // Change avec ton chemin d’image
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          applicationName: 'Check-it',
                          applicationVersion: '1.0.6',
                          applicationLegalese: '© 2025 Inturk Oran',

                          children: [
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).translate('checkItDescription'),

                              textAlign: TextAlign.justify,
                            ),
                          ],
                        );
                      },
                      child: Lottie.asset('assets/lotties/1 (128).json'),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedTextField(
                    // fieldKey: _numeroFieldKey,
                    controller: numeroController,
                    labelText: AppLocalizations.of(context).translate('number'),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                    ],
                    resetOnClear: true,
                    isNumberPhone: true,
                    onTextCleared: () {
                      setState(() {
                        _showSignalBtn =
                            true; // Ceci sera appelé quand le champ est vidé
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _showSignalBtn
                      ? SizedBox.shrink()
                      : _showDetail
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  ).translate('reason'),
                                  alignLabelWithHint: true,
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).translate('longtext'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(15),
                                ),
                                value: selectedMotif,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMotif = newValue!;
                                  });
                                },
                                items:
                                    motifs.map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate(value),
                                        ),
                                      );
                                    }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    ).translate('valide');
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showDetail = !_showDetail;
                                });
                              },
                              icon: Icon(
                                _showDetail ? FontAwesomeIcons.arrowDown : null,
                                size: 17,
                              ),
                            ),
                            //child: Text(_showDetail ? "Ajouter Motif" : 'Reduire')),
                          ],
                        ),
                      )
                      : SizedBox.shrink(),
                  _showSignalBtn
                      ? SizedBox.shrink()
                      : _showDetail
                      ? SizedBox.shrink()
                      : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                              child: AnimatedLongTextField(
                                controller: motifController,
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('reason'),
                                validator: (value) {
                                  return null;

                                  // if (value == null || value.isEmpty) {
                                  //   return 'Veuillez entrer un motif';
                                  // }
                                  // return null;
                                },
                                isNumberPhone: false,
                              ),
                            ),
                            // AnimatedTextField(
                            //   controller: motifController,
                            //   labelText: 'Motif',
                            //   validator: (value) {
                            //     // if (value == null || value.isEmpty) {
                            //     //   return 'Veuillez entrer un motif';
                            //     // }
                            //     // return null;
                            //   },
                            //   isNumberPhone: false,
                            // ),
                          ),
                          IconButton(
                            padding: EdgeInsets.fromLTRB(0, 28, 0, 0),
                            onPressed: () {
                              setState(() {
                                _showDetail = !_showDetail;
                              });
                            },
                            icon: Icon(FontAwesomeIcons.arrowUp, size: 17),
                          ),
                        ],
                      ),
                  _showSignalBtn ? SizedBox.shrink() : SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        _showSignalBtn
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                    children: [
                      _showSignalBtn
                          ? SizedBox.shrink()
                          : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            onPressed: () async {
                              if (_user != null) {
                                if (_formKey.currentState!.validate()) {
                                  final numero = provider
                                      .normalizeAndValidateAlgerianPhone(
                                        numeroController.text.trim(),
                                      );

                                  if (numero == null) {
                                    _showErrorDialog(
                                      AppLocalizations.of(
                                        context,
                                      ).translate('invalideNumber'),
                                    );
                                    return;
                                  }

                                  // Vérification si le numéro a déjà été signalé par l'utilisateur
                                  final alreadyReported = await provider
                                      .checkIfAlreadyReported(
                                        numero,
                                        _user!.uid,
                                      );
                                  print(numero);
                                  print(_user!.uid);

                                  if (alreadyReported) {
                                    _showErrorDialog(
                                      '${AppLocalizations.of(context).translate('dejaSignaler')}\n0$numero.',
                                    );
                                    return;
                                  }

                                  final signalement = Signalement(
                                    numero: numero,
                                    signalePar: _user!.displayName!,
                                    motif: motifController.text.trim(),
                                    gravite: 1,
                                    description: selectedMotif,
                                    date: DateTime.now(),
                                    user: _user!.uid,
                                  );

                                  await provider.ajouterSignalement(
                                    signalement,
                                    _user!.uid,
                                  );

                                  // Réinitialiser les champs
                                  numeroController.clear();
                                  motifController.clear();

                                  setState(() {
                                    selectedMotif = motifs.first;
                                    numeroRecherche = numero;
                                    _showSignalBtn = !_showSignalBtn;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${AppLocalizations.of(context).translate('leNum')}\n0$numero  ${AppLocalizations.of(context).translate('abien')}.',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => googleBtn(),
                                  ),
                                );
                              }
                            },
                            label: Text(
                              AppLocalizations.of(
                                context,
                              ).translate('signaler'),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                      SizedBox(width: 10),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            //////////////////////////////////////////////////////////////
                            // if (_isInterstitialAdReady) {
                            //   _interstitialAd?.show();
                            // } else {
                            //   print("L'annonce interstitielle n'est pas prête");
                            // }
                            //////////////////////////////////////////////////////////////
                            if (_user == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => googleBtn(),
                                ),
                              );
                            } else {
                              setState(() {
                                numeroRecherche = null;
                              });
                              final numero = provider
                                  .normalizeAndValidateAlgerianPhone(
                                    numeroController.text.trim(),
                                  );

                              if (numero == null) {
                                _showErrorDialog(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('invalideNumber'),
                                );
                                return;
                              }

                              setState(() {
                                numeroRecherche = numero;
                              });
                              _showSignalementDialog(
                                context,
                                numeroRecherche!,
                                provider,
                              );
                              setState(() {
                                _showSignalBtn = false;
                              });
                            }
                          },
                          label: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('rechercher'),
                          ),
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Spacer(),
                  Center(
                    child: InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://check31-a2fdf.web.app/',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw '${AppLocalizations.of(context).translate('impossibledouvrir')} $url';
                        }
                      },
                      child: Text(
                        '${AppLocalizations.of(context).translate('website')}',

                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  if (_bannerAd != null)
                    Expanded(
                      child: Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  _user == null || _user!.email != 'forslog@gmail.com'
                      ? SizedBox.shrink()
                      : InkWell(
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => MyApp000()),
                            ),
                        child: SizedBox(
                          height: 180,
                          width: 180,
                          child: Lottie.asset('assets/lotties/1 (26).json'),
                        ),
                      ),
                  SizedBox(height: 100),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class googleBtn extends StatefulWidget {
  @override
  _googleBtnState createState() => _googleBtnState();
}

class _googleBtnState extends State<googleBtn> {
  final AuthService _authService = AuthService();
  User? _user;
  bool isLoading = false;
  List<Map<String, dynamic>> _reportedNumbers = [];
  bool hasMore = true;
  int currentPage = 0;
  final int pageSize = 10; // Nombre de résultats par page
  bool isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _setupAuthListener();
    if (_user != null) {
      _loadReportedNumbers();
    }
  }

  Future<void> _loadReportedNumbers() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      final data = await su.Supabase.instance.client
          .from('signalements')
          .select('numero, date') // Ajouter le champ date ici
          .eq('user', _user!.uid)
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1)
          .order('date', ascending: false);

      setState(() {
        _reportedNumbers.addAll(List<Map<String, dynamic>>.from(data));
        hasMore = data.length == pageSize;
        if (hasMore) currentPage++;
      });
      // Debug: Vérifier les données reçues
      print('Données avec date: ${data.map((e) => e['date'])}');
    } catch (e) {
      if (e is su.PostgrestException) {
        print('Erreur de pagination: ${e.details}');
      }
      hasMore = false;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteReportedNumber(String numero) async {
    try {
      await su.Supabase.instance.client
          .from('signalements')
          .delete()
          .eq('numero', numero)
          .eq('user', _user!.uid);

      setState(() {
        _reportedNumbers.removeWhere((item) => item['numero'] == numero);
      });
    } catch (e) {
      print('Erreur suppression: ${e.toString()}');
    }
  }

  Future<void> _deleteAllReportedNumbers() async {
    try {
      await su.Supabase.instance.client
          .from('signalements')
          .delete()
          .eq('user', _user!.uid);

      setState(() => _reportedNumbers.clear());
    } catch (e) {
      print('Erreur suppression totale: ${e.toString()}');
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => isLoading = true);

    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // Recharge les données utilisateur
        Provider.of<SignalementProviderSupabase>(
          context,
          listen: false,
        ).chargerSignalements(user.uid);

        Navigator.pushReplacement(
          // Force le rafraîchissement
          context,
          MaterialPageRoute(builder: (ctx) => HomePage3()),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => isSigningOut = true);

    try {
      // On attend que les deux futures se terminent : la déconnexion + le délai
      await Future.wait([
        _authService.signOut(),
        Future.delayed(const Duration(seconds: 2)), // 👈 délai imposé
      ]);

      setState(() {
        _user = null;
        _reportedNumbers.clear();
      });
    } catch (e) {
      print('Erreur déconnexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('connexErreur')),
        ),
      );
    } finally {
      setState(() => isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signalementProvider = Provider.of<SignalementProviderSupabase>(
      context,
    );
    return Scaffold(
      appBar: AppBar(
        title:
            _user == null
                ? SizedBox.shrink()
                : AppLocalizations.of(context).locale.languageCode != 'ar'
                ? Text('${AppLocalizations.of(context).translate('profil')}')
                : Text(
                  '${AppLocalizations.of(context).translate('profil')}',
                  style: const TextStyle(fontFamily: 'ArbFONTS'),
                ),
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : _user == null
                ? _buildLoginUI()
                : _buildProfileUI(signalementProvider),
      ),
    );
  }

  Widget _buildLoginUI() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lotties/google.json',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),

            AppLocalizations.of(context).locale.languageCode != 'ar'
                ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),

                    child: Text(
                      '${AppLocalizations.of(context).translate('usingGoogleToReport')}'
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Oswald',
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Text(
                      '${AppLocalizations.of(context).translate('usingGoogleToReport')}'
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'ArbFONTS',
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4.0,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: Icon(FontAwesomeIcons.google, color: Colors.red),
              label: const Text(
                'Google',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              onPressed: _handleSignIn,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // 1. D'abord, modifions la méthode _buildProfileUI
  Widget _buildProfileUI(signalementProvider) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Carte de profil
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundImage:
                                      _user?.photoURL != null
                                          ? NetworkImage(_user!.photoURL!)
                                          : AssetImage(
                                                'assets/images/default_avatar.png',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _user?.displayName ??
                                    '${AppLocalizations.of(context).translate('user')}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  //padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _handleSignOut,
                                icon: Icon(
                                  Icons.logout,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                label: Text(
                                  '${AppLocalizations.of(context).translate('deconex')}',
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed:
                                    () =>
                                        _showDeleteAccountConfirmation(context),
                                child: Text(
                                  '${AppLocalizations.of(context).translate('defini')}',

                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Divider
                    if (_reportedNumbers.length != 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Divider(),
                      ),

                    // Animation Lottie quand il n'y a pas de signalements
                    if (_reportedNumbers.length == 0)
                      Container(
                        height: 250,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Lottie.asset('assets/lotties/1 (123).json'),
                      ),
                  ],
                ),
              ),

              // Liste des signalements
              if (_reportedNumbers.length > 0)
                SliverFillRemaining(
                  child: _buildReportedNumbersListContent(signalementProvider),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Créons une nouvelle méthode pour le contenu de la liste sans Expanded
  Widget _buildReportedNumbersListContent(signalementProvider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 500) {
          _loadReportedNumbers();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     'Signalements récents',
            //     style: TextStyle(
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
            // ),
            // SizedBox(height: 8),
            // _reportedNumbers.length == 0
            //     ? SizedBox.shrink()
            //     : Padding(
            //         padding: const EdgeInsets.only(right: 8),
            //         child: TextButton(
            //           onPressed: () => _deleteAllReportedNumbers(),
            //           child: Text(
            //             'Delete All',
            //             textAlign: TextAlign.end,
            //             style: TextStyle(fontSize: 12, color: Colors.red),
            //           ),
            //         ),
            //       ),
            _reportedNumbers.length == 0
                ? SizedBox.shrink()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '${AppLocalizations.of(context).translate('sRecent')}',

                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: () => confirmDeleteAll(context),
                        // onPressed: () => _deleteAllReportedNumbers(),
                        child: Text(
                          '${AppLocalizations.of(context).translate('deleteAll')}',

                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // Changé pour permettre le défilement
                itemCount: _reportedNumbers.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _reportedNumbers.length) {
                    return Center(
                      child:
                          hasMore
                              ? const CircularProgressIndicator()
                              : Text(
                                '${AppLocalizations.of(context).translate('fin')}',
                              ),
                    );
                  }

                  final reportedNumber = _reportedNumbers[index];

                  return Material(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: Colors.deepPurple.shade50,
                        dense: true,
                        leading: FutureBuilder<int>(
                          future: signalementProvider.nombreSignalements(
                            reportedNumber['numero'],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return MyShimmerCircleAvatar();
                            }
                            return CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                NumberFormat.compact().format(
                                  snapshot.data ?? 0,
                                ), // 1500 → "1.5K"
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              // Text(
                              //   snapshot.hasData
                              //       ? snapshot.data.toString()
                              //       : '0',
                              //   style: TextStyle(
                              //     fontSize: 20,
                              //     color:
                              //         Theme.of(context).colorScheme.onPrimary,
                              //   ),
                              // ),
                            );
                          },
                        ),
                        title: Text(
                          formatPhoneNumber('0${reportedNumber['numero']}'),
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          reportedNumber['date'] != null
                              ? timeago.format(
                                DateTime.parse(
                                  reportedNumber['date']!,
                                ).toLocal(),
                                locale:
                                    'fr', // Optionnel - pour avoir les textes en français
                              )
                              : '${AppLocalizations.of(context).translate('dateInconnu')}',

                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        // Text(
                        //   reportedNumber['date'] != null
                        //       ? DateFormat('dd/MM/yyyy HH:mm').format(
                        //           DateTime.parse(reportedNumber['date']!)
                        //               .toLocal())
                        //       : 'Date inconnue',
                        //   style: TextStyle(fontSize: 11),
                        // ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 23,
                            color: Colors.red,
                          ),
                          onPressed:
                              () => confirmDeleteNumero(
                                context,
                                reportedNumber['numero'],
                              ),
                          //    _deleteReportedNumber(reportedNumber['numero']),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          _user = user;
        });
        _loadReportedNumbers(); // Recharge les données quand l'utilisateur se connecte
      }
    });
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    final scaffoldContext = context;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              '${AppLocalizations.of(context).translate('validateRequise')}',
            ),
            content: Text(
              '${AppLocalizations.of(context).translate('actionDeleting')}',
            ),
            actions: [
              TextButton(
                child: Text(
                  '${AppLocalizations.of(context).translate('annuler')}',
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  '${AppLocalizations.of(context).translate('confirme')}',
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  final success =
                      await _authService.deleteUserAccountPermanently();

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context).translate('deleteSucces')}',
                          ),
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        scaffoldContext,
                        MaterialPageRoute(builder: (_) => HomePage3()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context).translate('deleteEchec')}',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  String formatPhoneNumber(String rawNumber) {
    // Supprime tous les caractères non numériques
    String digitsOnly = rawNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Vérifie que le numéro commence par 0 et a 10 chiffres
    if (digitsOnly.length == 10 && digitsOnly.startsWith('0')) {
      return '${digitsOnly.substring(0, 2)}.' // 06.
          '${digitsOnly.substring(2, 4)}.' // 60.
          '${digitsOnly.substring(4, 6)}.' // 52.
          '${digitsOnly.substring(6, 8)}.' // 02.
          '${digitsOnly.substring(8)}'; // 25
    }

    // Retourne le numéro original si le format n'est pas reconnu
    return rawNumber;
  }

  void confirmDeleteAll(BuildContext context) {
    showConfirmationDialog(
      context: context,
      title: '${AppLocalizations.of(context).translate('deleteAllReports')}',

      content:
          '${AppLocalizations.of(context).translate('deleteAllReportsConfirmation')}',
      onConfirm: _deleteAllReportedNumbers,
    );
  }

  void confirmDeleteNumero(BuildContext context, String numero) {
    showConfirmationDialog(
      context: context,
      title: '${AppLocalizations.of(context).translate('confirmDeletion')}',
      content:
          '${AppLocalizations.of(context).translate('confirmReportDeletion')}',
      onConfirm: () => _deleteReportedNumber(numero),
    );
  }

  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: Text(
                  '${AppLocalizations.of(context).translate('annuler')}',
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: Text(
                  '${AppLocalizations.of(context).translate('delete')}',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Ferme la boîte de dialogue
                  onConfirm(); // Appelle la fonction de suppression
                },
              ),
            ],
          ),
    );
  }
}

class MyShimmerCircleAvatar extends StatelessWidget {
  const MyShimmerCircleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.primary,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

void _showSignalementDialog(
  BuildContext context,
  String numeroRecherche,
  SignalementProviderSupabase provider,
) async {
  final nbSignalements = await provider.nombreSignalements(numeroRecherche);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo opérateur
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      provider.getLogoOperateur(
                                    provider.detecterOperateur(numeroRecherche),
                                  ) ==
                                  null ||
                              provider
                                  .getLogoOperateur(
                                    provider.detecterOperateur(numeroRecherche),
                                  )
                                  .isEmpty
                          ? Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            ),
                          )
                          : Image(
                            image:
                                provider
                                        .getLogoOperateur(
                                          provider.detecterOperateur(
                                            numeroRecherche,
                                          ),
                                        )
                                        .startsWith('http')
                                    ? CachedNetworkImageProvider(
                                      provider.getLogoOperateur(
                                        provider.detecterOperateur(
                                          numeroRecherche,
                                        ),
                                      ),
                                      errorListener:
                                          (error) => debugPrint("Image error"),
                                    )
                                    : AssetImage(
                                      provider.getLogoOperateur(
                                        provider.detecterOperateur(
                                          numeroRecherche,
                                        ),
                                      ),
                                    ),
                            fit: BoxFit.contain,
                          ),
                ),
              ),
              SizedBox(height: 10),

              // Texte signalement
              SelectableText(
                nbSignalements == 0
                    ? '${AppLocalizations.of(context).translate('user')}\n0$numeroRecherche'
                    : '${AppLocalizations.of(context).translate('ceNum')}\n0$numeroRecherche ${AppLocalizations.of(context).translate('hasBeenRepo')}',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              nbSignalements == 0 ? SizedBox.shrink() : SizedBox(height: 10),
              nbSignalements == 0
                  ? SizedBox.shrink()
                  : CircleAvatar(
                    child: Text(
                      nbSignalements.toString(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    maxRadius: 30,
                    minRadius: 30,
                    backgroundColor: getColorForSignalements(nbSignalements),
                  ),
              SizedBox(height: 10),
              nbSignalements == 0
                  ? SizedBox.shrink()
                  : Text("${AppLocalizations.of(context).translate('fois')}"),
              nbSignalements == 0 ? SizedBox.shrink() : SizedBox(height: 10),
              DangerBarWithAnimation(degree: nbSignalements),
              SizedBox(height: 10),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("${AppLocalizations.of(context).translate('fermer')}"),
          ),
        ],
      );
    },
  );
}

class DangerBarWithAnimation extends StatefulWidget {
  final int degree; // Le degré de gravité entre 1 et 5

  DangerBarWithAnimation({required this.degree});

  @override
  _DangerBarWithAnimationState createState() => _DangerBarWithAnimationState();
}

class _DangerBarWithAnimationState extends State<DangerBarWithAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // On crée une animation qui déplace la flèche en fonction du degré
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // L'animation qui déplace la flèche
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.degree.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Lancer l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Retourne le texte associé au degré de gravité

  String getTextForSignalementss(int signalements) {
    if (signalements == 0) {
      return 'Ce numéro n\'a jamais été signalé.';
    } else if (signalements == 1) {
      return 'Ce numéro présente un risque modéré.';
    } else if (signalements == 2) {
      return 'Ce numéro présente un risque moyen.';
    } else if (signalements == 3 || signalements == 4) {
      return 'Ce numéro présente un risque élevé.';
    } else if (signalements >= 5) {
      return 'Ce numéro présente un risque très élevé.';
    } else {
      return 'État de signalement inconnu.';
    }
  }

  String getTextForSignalementsContext(BuildContext context, int signalements) {
    if (signalements == 0) {
      return AppLocalizations.of(context).translate('numeroJamaisSignale');
    } else if (signalements == 1) {
      return AppLocalizations.of(context).translate('numeroRisqueModere');
    } else if (signalements == 2) {
      return AppLocalizations.of(context).translate('numeroRisqueMoyen');
    } else if (signalements == 3 || signalements == 4) {
      return AppLocalizations.of(context).translate('numeroRisqueEleve');
    } else if (signalements >= 5) {
      return AppLocalizations.of(context).translate('numeroRisqueTresEleve');
    } else {
      return AppLocalizations.of(context).translate('etatSignalementInconnu');
    }
  }

  // Retourne le chemin du fichier Lottie associé au degré de gravité
  String getLottieFilePathForDegree(int signalements) {
    if (signalements == 0) {
      return 'assets/lotties/1 (7).json';
    } else if (signalements == 1) {
      return 'assets/lotties/1 (27).json';
    } else if (signalements == 2) {
      return 'assets/lotties/1 (71).json';
    } else if (signalements == 3 || signalements == 4) {
      return 'assets/lotties/1 (124).json';
    } else if (signalements >= 5) {
      return 'assets/lotties/1 (123).json';
    } else {
      return 'assets/lotties/1 (129).json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Lottie.asset(getLottieFilePathForDegree(widget.degree)),
        ),
        SelectableText(
          getTextForSignalementsContext(context, widget.degree),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: getColorForSignalements(widget.degree),
          ),
        ),
      ],
    );
  }
}

// Retourne la couleur associée au degré de gravité
Color getColorForSignalements(int signalements) {
  if (signalements == 0) {
    return Colors.green;
  } else if (signalements == 1) {
    return Colors.lightGreen;
  } else if (signalements == 2) {
    return Colors.blue;
  } else if (signalements == 3 || signalements == 4) {
    return Colors.orange;
  } else if (signalements >= 5) {
    return Colors.red;
  } else {
    return Colors.grey;
  }
}

final List<TyperAnimatedText> animatedWords =
    [
      'Contrôlé',
      'Confirmé',
      'Validé',
      'Attesté',
      'Approuvé',
      'Inspecté',
      'Évalué',
      'Testé',
      'Examiné',
      'Vérifié',
      'Révisé',
      'Analysé',
      'Diagnostiqué',
      'Consulte',
      'Essaie',
      'Analyse',
      'Teste',
      'Inspecte',
      'Examine',
      'Observe',
      'Explore',
      'Déclaré',
      'Marqué',
      'Annoncé',
      'Dénoncé',
      'Pointé',
      'Alerté',
      'Identifié',
      'Détécté',
      'Écarté',
      'Contourné',
      'Prévenu',
      'Empêché',
      'Anticipé',
      'Déjoué',
      'Neutralisé',
      'Protégé',
      'Révoqué',
    ].map((word) {
      return TyperAnimatedText(
        word,
        textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
      );
    }).toList();
