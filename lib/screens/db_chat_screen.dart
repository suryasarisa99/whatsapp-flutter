import 'package:flutter/material.dart';
import 'package:whatsapp_chat/components/chat_appbar.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
import 'package:whatsapp_chat/components/chat_input.dart';
import 'package:whatsapp_chat/components/message_bubble.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class DbChatScreen extends StatefulWidget {
  const DbChatScreen({super.key, required this.data});
  final DbMssgs data;

  @override
  State<DbChatScreen> createState() => _DbChatScreenState();
}

class _DbChatScreenState extends State<DbChatScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.data.mssgs.length);
    return Scaffold(
        appBar: ChatAppbar(
            title: widget.data.chat.groupName ?? widget.data.chat.no),
        body: Stack(
          children: [
            const ChatBackground(),
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    // shrinkWrap: true,
                    itemCount: widget.data.mssgs.length,
                    itemBuilder: (context, index) {
                      final mssg = widget.data.mssgs[index];
                      return Row(
                        mainAxisAlignment: mssg.me == 1
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          MssgBubble(
                            mssg,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ChatInputField(),
              ],
            )
          ],
        ));
  }
}
