import 'package:shopping/core/imports/imports.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_button.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_logo_auth.dart';
import 'package:shopping/features/presentation/screens/auth/widget/custom_text_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await credential.user!.sendEmailVerification();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/LoginPage');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: l10n.registrationErrorTitle,
            desc: e.message ?? l10n.genericErrorMessage,
            transitionAnimationDuration: const Duration(seconds: 1),
          ).show();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const CustomLogoAuth(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.signUpButton,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextForm(
                    hintText: l10n.usernameHint,
                    controller: usernameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l10n.emptyFieldError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextForm(
                    hintText: l10n.emailHint,
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l10n.emptyFieldError;
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
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
                  CustomTextForm(
                    hintText: l10n.confirmPasswordHint,
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l10n.emptyFieldError;
                      } else if (value != passwordController.text) {
                        return l10n.passwordMismatchError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            CustomButton(
              title: l10n.signUpButton,
              onPressed: signUp,
              textColor: AppTheme.contentColor,
            ),
          ],
        ),
      ),
    );
  }
}
