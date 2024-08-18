import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      forceMaterialTransparency: true,
      title: Text('WhatsApp',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                  : Theme.of(context).colorScheme.primary,
              fontSize: 26)),
      actions: const [
        Icon(Icons.qr_code_scanner_outlined),
        SizedBox(width: 22),
        Icon(Icons.camera_alt_outlined),
        SizedBox(width: 22),
        Icon(Icons.more_vert),
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}
