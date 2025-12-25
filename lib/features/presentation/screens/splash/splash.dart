import 'package:shopping/core/imports/imports.dart';

import 'introduction_app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Future.delayed( Duration(seconds: 2), _navigateToWalkthrough);
  }

  void _navigateToWalkthrough() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  IntroductionApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        margin:  EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart,
                  size: 100.0, color: AppTheme.primaryColor),
              SizedBox(height: 20),
              Text(l10n.welcomemycart,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
