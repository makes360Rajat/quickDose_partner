import 'dart:ui' as ui;
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/helper/services/analytics_service.dart';
import 'package:project/helper/services/crashlytics_service.dart';
import 'package:project/provider/policyAndTermsProvider.dart';
import 'package:project/provider/deliveryBoyStatusProvider.dart';
import 'package:project/provider/sellerStatusProvider.dart';
import 'package:project/provider/homeMainScreenProvider.dart';
import 'package:project/provider/productTranslationProvider.dart';
import 'package:project/provider/logoutProvider.dart';
import 'package:project/repositories/productTranslationApi.dart';

import 'helper/utils/generalImports.dart';

late final SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

  prefs = await SharedPreferences.getInstance();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Initialize Firebase Analytics
    await AnalyticsService.initialize();

    // Initialize Firebase Crashlytics
    await CrashlyticsService.initialize();

    // Handle Flutter framework errors
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {}

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: ColorsRes.appColorTransparent));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
          create: (context) {
            return LanguageProvider();
          },
        ),
        ChangeNotifierProvider<ProductListProvider>(
          create: (context) {
            return ProductListProvider();
          },
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) {
            return SettingsProvider();
          },
        ),
        ChangeNotifierProvider<SellerStatusProvider>(
          create: (context) {
            return SellerStatusProvider();
          },
        ),
        ChangeNotifierProvider<DeliveryBoyStatusProvider>(
          create: (context) {
            return DeliveryBoyStatusProvider();
          },
        ),
        ChangeNotifierProvider<CategoryListProvider>(
          create: (context) {
            return CategoryListProvider();
          },
        ),
        ChangeNotifierProvider<PolicyAndTermsProvider>(
          create: (context) {
            return PolicyAndTermsProvider();
          },
        ),
        ChangeNotifierProvider<HomeMainScreenProvider>(
          create: (context) {
            return HomeMainScreenProvider();
          },
        ),
        ChangeNotifierProvider<ProductTranslationProvider>(
          create: (context) {
            return ProductTranslationProvider(
              repository: ProductTranslationRepository(),
            );
          },
        ),
        ChangeNotifierProvider<LogoutProvider>(
          create: (context) {
            return LogoutProvider();
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SessionManager>(
      create: (_) => SessionManager(prefs: prefs),
      child: Consumer<SessionManager>(
        builder: (context, SessionManager sessionNotifier, child) {
          Constant.session =
              Provider.of<SessionManager>(context, listen: false);

          if (Constant.session
              .getData(SessionManager.appThemeName)
              .toString()
              .isEmpty) {
            Constant.session.setData(
                SessionManager.appThemeName, Constant.themeList[0], false);
            Constant.session.setBoolData(
                SessionManager.isDarkTheme,
                ui.PlatformDispatcher.instance.platformBrightness ==
                    Brightness.dark,
                false);
          }

          // This callback is called every time the brightness changes from the device.
          ui.PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
            if (Constant.session.getData(SessionManager.appThemeName) ==
                Constant.themeList[0]) {
              Constant.session.setBoolData(
                  SessionManager.isDarkTheme,
                  ui.PlatformDispatcher.instance.platformBrightness ==
                      Brightness.dark,
                  true);
            }
          };

          return Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              Constant.session = Provider.of<SessionManager>(context);

              if (Constant.session
                  .getData(SessionManager.appThemeName)
                  .toString()
                  .isEmpty) {
                Constant.session.setData(
                    SessionManager.appThemeName, Constant.themeList[0], false);
                Constant.session.setBoolData(
                    SessionManager.isDarkTheme,
                    ui.PlatformDispatcher.instance.platformBrightness ==
                        Brightness.dark,
                    false);
              }

              // This callback is called every time the brightness changes from the device.
              ui.PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
                if (Constant.session.getData(SessionManager.appThemeName) ==
                    Constant.themeList[0]) {
                  Constant.session.setBoolData(
                      SessionManager.isDarkTheme,
                      ui.PlatformDispatcher.instance.platformBrightness ==
                          Brightness.dark,
                      true);
                }
              };

              return /* AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle(systemNavigationBarColor:
                        ColorsRes.appColorTransparent,
                        systemNavigationBarDividerColor: ColorsRes.appColorTransparent,
                        statusBarColor: Theme.of(context).colorScheme.onSurface,
                        systemStatusBarContrastEnforced: true
                    ),
                    child: */MaterialApp(
                builder: (context, child) {
                  return ScrollConfiguration(
                    behavior: GlobalScrollBehavior(),
                    child: Directionality(
                      textDirection:
                          languageProvider.languageDirection.toLowerCase() ==
                                  "rtl"
                              ? ui.TextDirection.rtl
                              : ui.TextDirection.ltr,
                      child: /* Overlay(
                        initialEntries: [
                          OverlayEntry(builder: (context) => child!),
                        ],
                      ) */ Overlay(
                        initialEntries: [
                          OverlayEntry(
                            builder: (context) => SafeArea(bottom: Platform.isAndroid ? true : false, top: false, child: child!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                navigatorKey: Constant.navigatorKay,
                navigatorObservers: [
                  if (AnalyticsService.observer != null) AnalyticsService.observer!,
                ],
                onGenerateRoute: RouteGenerator.generateRoute,
                initialRoute: "/",
                scrollBehavior: ScrollGlowBehavior(),
                debugShowCheckedModeBanner: false,
                title: Constant.appName,
                theme: ColorsRes.setAppTheme().copyWith(
                  textTheme:
                      GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
                ),
                home: SplashScreen(),
              )/* ) */;
            },
          );
        },
      ),
    );
  }
}