import 'package:shopping/core/imports/imports.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_button.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_logo_auth.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_text_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  Future<void> signInWithEmailAndPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (credential.user!.emailVerified) {
          Navigator.of(context).pushReplacementNamed('/BottomNavBar');
        } else {
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'خطأ في تسجيل الدخول',
              desc: 'يرجى التحقق من بريدك الإلكتروني.',
            ).show();
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'خطأ في تسجيل الدخول',
              desc: 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني.',
            ).show();
          }
        } else if (e.code == 'wrong-password') {
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'خطأ في تسجيل الدخول',
              desc: 'كلمة المرور غير صحيحة لهذا المستخدم.',
            ).show();
          }
        } else {
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.rightSlide,
              title: 'خطأ في تسجيل الدخول',
              desc: e.message,
            ).show();
          }
        }
      }
    } else {
      print("النموذج غير صالح");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // المستخدم ألغى تسجيل الدخول
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pushNamedAndRemoveUntil('/BottomNavBar', (route) => false);
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'خطأ في تسجيل الدخول',
        desc: 'فشل تسجيل الدخول باستخدام Google. حاول مرة أخرى',

      ).show();
    }
  }


  void _showErrorDialog({required String title, required String description}) {
    if (mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: title,
        desc: description,
      ).show();
    }
  }

  /// التعامل مع استثناءات FirebaseAuth
  void _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني.';
        break;
      case 'wrong-password':
        message = 'كلمة المرور غير صحيحة.';
        break;
      default:
        message = e.message ?? 'حدث خطأ غير متوقع.';
    }

    _showErrorDialog(
      title: 'خطأ في تسجيل الدخول',
      description: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const CustomLogoAuth(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.loginButton,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextForm(
                    hintText: l10n.emailHint,
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l10n.emptyFieldError;
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return l10n.invalidEmailError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextForm(
                    hintText: l10n.passwordHint,
                    controller: passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l10n.emptyFieldError;
                      } else if (value.length < 6) {
                        return l10n.passwordLengthError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () async {
                        if (emailController.text.isEmpty) {
                          _showErrorDialog(
                            title: l10n.error,
                            description: l10n.enterEmailBeforeForgotPassword,
                          );
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailController.text.trim());
                          _showErrorDialog(
                            title: l10n.success,
                            description: l10n.checkEmailForReset,
                          );
                        } catch (e) {
                          _showErrorDialog(
                            title: l10n.error,
                            description: l10n.checkEmailError,
                          );
                        }
                      },
                      child: Text(
                        l10n.forgotPassword,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: l10n.loginButton,
              onPressed: signInWithEmailAndPassword,
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: l10n.googleLoginButton,
              onPressed: signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
