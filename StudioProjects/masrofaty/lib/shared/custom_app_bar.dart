import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool isLoading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(title),
      actions: [
        if (isLoading) const CircularProgressIndicator(strokeWidth: 2),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
