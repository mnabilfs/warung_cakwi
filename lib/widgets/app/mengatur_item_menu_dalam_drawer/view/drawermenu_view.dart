import 'package:flutter/material.dart';

class DrawerMenuView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const DrawerMenuView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = Colors.white;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        // Jika textColor ada, gunakan itu. Jika tidak, pakai default.
        style: TextStyle(color: textColor ?? defaultTextColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              // 🔴 PENYESUAIAN 2: Gunakan properti textColor untuk Subtitle (dengan opacity)
              style: TextStyle(
                color: (textColor ?? defaultTextColor).withOpacity(0.7),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
