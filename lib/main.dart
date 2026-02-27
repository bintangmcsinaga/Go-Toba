// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_toba/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_toba/Home/SplashScreen.dart';
import 'package:go_toba/Login&Register/login.dart';
import 'package:go_toba/Login&Register/register.dart';
import 'package:go_toba/MainPage.dart';
import 'package:go_toba/Providers/LocaleProv.dart';
import 'package:go_toba/Providers/NavBarProv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_toba/Providers/ResetPasswordProv.dart';
import 'package:go_toba/Providers/UserProv.dart';
import 'package:go_toba/style.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: localeProvider),
    ChangeNotifierProvider(create: (_) => NavBarProv()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.latoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
      navigatorObservers: [routeObserver],
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
