
import 'package:shopping/core/imports/imports.dart';

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});
  @override
  MyAppState createState() => MyAppState();
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(locale);
  }
}
class MyAppState extends State<MyApp> {
  late Locale _locale;
  @override
  void initState() {
    super.initState();
    _locale = _getSavedLocale();
  }
  Locale _getSavedLocale() {
    final languageCode = widget.prefs.getString('language_code') ?? 'en';
    final countryCode = widget.prefs.getString('country_code') ?? 'US';
    return Locale(languageCode, countryCode);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    widget.prefs.setString('language_code', locale.languageCode);
    widget.prefs.setString('country_code', locale.countryCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider(widget.prefs)),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale, // اللغة الحالية
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'AE'),
              Locale('fr', 'FR'),
              Locale('es', 'ES'),
              Locale('de', 'DE'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: '/SplashScreen',
            onGenerateRoute: onGenerateRoute,
          );
        },
      ),
    );
  }
}
