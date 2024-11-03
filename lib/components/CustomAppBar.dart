import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onSidebarButtonPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onBackButtonPressed,
    required this.onSidebarButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackButtonPressed,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu), // Or any other icon for the sidebar
          onPressed: onSidebarButtonPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}