import 'package:flutter/material.dart';

class CustomMenuItem extends PopupMenuItem {
  CustomMenuItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
  }) : super(
          child: Row(children: [
            Icon(icon),
            SizedBox(width: 16),
            ConstrainedBox(
                constraints: BoxConstraints(minWidth: 90), child: Text(title))
          ]),
          onTap: onTap,
        );

  final String title;
  final IconData icon;
  void Function() onTap;
}
