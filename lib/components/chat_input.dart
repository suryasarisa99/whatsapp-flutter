import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.emoji_emotions_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.attach_file_outlined,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                ),
                placeholder: "Message",
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.primaryContainer,
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .dec(context, 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
          ),
          SizedBox(width: 6),
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary.darken(0.12),
            child: Icon(
              Icons.mic,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        ],
      ),
    );
  }
}
