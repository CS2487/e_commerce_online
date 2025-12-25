import 'package:shopping/core/imports/imports.dart';
enum ScreenSize {
  small(300),
  normal(400),
  large(600),
  extraLarge(1200);

  final double size;

  const ScreenSize(this.size);
}
ScreenSize getScreenSize(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.shortestSide;

  if (screenWidth > ScreenSize.extraLarge.size) {
    return ScreenSize.extraLarge;
  } else if (screenWidth > ScreenSize.large.size) {
    return ScreenSize.large;
  } else if (screenWidth > ScreenSize.normal.size) {
    return ScreenSize.normal;
  } else {
    return ScreenSize.small;
  }
}
