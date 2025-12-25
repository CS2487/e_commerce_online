
import 'package:shopping/core/imports/imports.dart';
class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color =  AppTheme.primaryColor,
    this.textColor = AppTheme.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 55,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color,
      textColor: textColor,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
