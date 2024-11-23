import 'package:flutter/material.dart';

const Color _themeColor = Color(0xFF3DA9FC);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback onSidebarButtonPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackButtonPressed,
    required this.onSidebarButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      leading: onBackButtonPressed != null
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: _themeColor,
              ),
              onPressed: onBackButtonPressed,
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {}),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.person_2_rounded,
            color: _themeColor,
          ),
          onPressed: onSidebarButtonPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
