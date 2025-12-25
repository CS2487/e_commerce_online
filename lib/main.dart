import 'core/imports/imports.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('========== User is currently signed out!!!');
      } else {
        print('========== User is signed in!!!');
      }
    });

    runApp(MyApp(prefs: prefs));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}
