import 'package:flutter/material.dart';

/// A reusable list tile widget specifically styled for the profile menu.
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: isDestructive ? Colors.red : theme.primaryColor, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
            : null,
        trailing: isDestructive
            ? null
            : Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
      ),
    );
  }
}
