import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class DbHomeSearchbar extends StatelessWidget {
  const DbHomeSearchbar({
    super.key,
    required this.focusNode,
    required this.textController,
    required this.handleChange,
  });

  final FocusNode focusNode;
  final TextEditingController textController;
  final void Function(String text) handleChange;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sbColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.lighten(0.05)
        : Theme.of(context).colorScheme.primaryContainer.lighten(0.14);
    return Hero(
      tag: 'home-search-bar',
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CupertinoTextField(
          placeholder: "Ask Meta Ai or Search",
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: sbColor,
          ),
          prefix: Padding(
              padding: EdgeInsets.zero,
              // padding: EdgeInsets.only(left: 16, right: 8, top: 13, bottom: 13),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, size: 24),
                  ),
                  Icon(Icons.search),
                ],
              )),
          onChanged: handleChange,
          controller: textController,
          focusNode: focusNode,
          onTapOutside: (x) {
            focusNode.unfocus();
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
