import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeleteMssgBubble extends StatelessWidget {
  const DeleteMssgBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FaIcon(FontAwesomeIcons.ban).icon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: 8),
          Text(
            "This message was deleted",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
