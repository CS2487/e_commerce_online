import 'package:shopping/core/imports/imports.dart';
class CustomLogoAuth extends StatelessWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart, size: 80,
            color: AppTheme.primaryColor
        ),
      ],
    );
  }
}
