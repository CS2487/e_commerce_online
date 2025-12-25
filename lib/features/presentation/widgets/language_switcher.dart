import 'package:shopping/core/imports/imports.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.changeLanguage),
      onTap: () => _showLanguageBottomSheet(context, l10n),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, AppLocalizations l10n) {
    final List<Map<String, dynamic>> languages = [
      {'name': l10n.english, 'locale': const Locale('en', 'US')},
      {'name': l10n.arabic, 'locale': const Locale('ar', 'AE')},
      {'name': l10n.french, 'locale': const Locale('fr', 'FR')},
      {'name': l10n.spanish, 'locale': const Locale('es', 'ES')},
      {'name': l10n.german, 'locale': const Locale('de', 'DE')},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    l10n.selectlanguage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return ListTile(
                      title: Text(language['name']),
                      onTap: () {
                        context
                            .read<LanguageProvider>()
                            .setLocale(language['locale']);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
