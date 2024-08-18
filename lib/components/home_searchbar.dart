import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class HomeSearchbar extends StatelessWidget {
  HomeSearchbar({super.key});

  @override
  final FocusNode focusNode = FocusNode();
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sbColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.lighten(0.05)
        : Theme.of(context).colorScheme.primaryContainer.lighten(0.14);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CupertinoTextField(
        placeholder: "Ask Meta Ai or Search",
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: sbColor,
        ),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8, top: 13, bottom: 13),
          child: Icon(Icons.search),
        ),
        focusNode: focusNode,
        onTapOutside: (x) {
          focusNode.unfocus();
        },
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }
}
