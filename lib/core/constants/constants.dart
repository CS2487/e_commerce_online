import 'package:shopping/core/imports/imports.dart';
class AppConstants {
  static List<Map<String, String>> pageInfos(BuildContext context) {
    return [
      {
        "title": AppLocalizations.of(context)!.walkthrough_title_1,
        "body": AppLocalizations.of(context)!.walkthrough_body_1,
        "img": "assets/images/slider2.png",
      },
      {
        "title": AppLocalizations.of(context)!.walkthrough_title_2,
        "body": AppLocalizations.of(context)!.walkthrough_body_2,
        "img": "assets/images/slider.png",
      },
      {
        "title": AppLocalizations.of(context)!.walkthrough_title_3,
        "body": AppLocalizations.of(context)!.walkthrough_body_3,
        "img": "assets/images/slider3.png",
      },
    ];
  }

  // Titles and Labels
  static String skipText(BuildContext context) => AppLocalizations.of(context)!.skipText;
  static String nextText(BuildContext context) => AppLocalizations.of(context)!.nextText;
  static String doneText(BuildContext context) => AppLocalizations.of(context)!.doneText;
}
