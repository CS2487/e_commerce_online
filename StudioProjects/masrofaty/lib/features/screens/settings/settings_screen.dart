import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (_, provider, __) {
        Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('الاعدادات'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _settingsGroup(
                context,
                "عام",
                [
                  _settingsCard(
                    context,
                    icon: Icons.palette_outlined,
                    title: "الثيم",
                    subtitle: _themeText(provider.themeMode),
                    onTap: () => _showThemeDialog(context, provider),
                  ),
                ],
              ),
              _settingsGroup(
                context,
                "الإشعارات",
                [
                  _dailyReminderTile(context, provider),
                ],
              ),
              _settingsGroup(
                context,
                "الحساب",
                [
                  _settingsCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "تعديل الميزانية",
                    onTap: () => _showBudgetsDialog(context, provider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================== widgets Helpers ========================

  Widget _settingsGroup(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 24, bottom: 8),
          child: Text(
            title.toUpperCase(),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _dailyReminderTile(BuildContext context, SettingsProvider provider) {
    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title: const Text("تفعيل التذكير اليومي"),
      subtitle: Text(provider.dailyReminder
          ? "الوقت: ${provider.dailyReminderTime.format(context)}"
          : "غير مفعل"),
      trailing: Switch(
        value: provider.dailyReminder,
        onChanged: (v) async {
          // لو شغل المستخدم الإشعارات → شغّلها وحفظها
          await provider.setDailyReminder(v);
        },
      ),
      onTap: provider.dailyReminder
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: provider.dailyReminderTime,
              );
              if (picked != null) {
                await provider.setDailyReminderTime(picked);
              }
            }
          : null,
    );
  }

  Widget _settingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
    );
  }

  String _themeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "فاتح";
      case ThemeMode.dark:
        return "داكن";
      case ThemeMode.system:
      default:
        return "حسب النظام";
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    final options = {
      "فاتح": ThemeMode.light,
      "داكن": ThemeMode.dark,
      "حسب النظام": ThemeMode.system,
    };
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("اختر نمط التطبيق"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map(
                (e) => RadioListTile<ThemeMode>(
                  title: Text(e.key),
                  value: e.value,
                  groupValue: provider.themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      provider.setThemeMode(v);
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showBudgetsDialog(BuildContext context, SettingsProvider provider) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final controllers = {
      for (var e in provider.budgets.entries)
        e.key: TextEditingController(
            text: e.value
                .toStringAsFixed(e.value.truncateToDouble() == e.value ? 0 : 2))
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل الميزانية"),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: entry.value,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "الميزانية لـ ${entry.key}",
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  for (var key in controllers.keys) {
                    await provider.setBudget(
                      key,
                      double.tryParse(controllers[key]!.text) ?? 0,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  "حفظ",
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
