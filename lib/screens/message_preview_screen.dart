import 'package:flutter/material.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/message_buble.dart';
import 'package:whatsapp_chat/components/message_bubble.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class MessagPreviewScreen extends StatefulWidget {
  const MessagPreviewScreen({super.key, required this.mssgs});
  final List<DbMssg> mssgs;

  @override
  State<MessagPreviewScreen> createState() => _MessagPreviewScreenState();
}

class _MessagPreviewScreenState extends State<MessagPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ChatBackground(),
          ListView.builder(
              itemBuilder: (context, index) {
                final mssg = widget.mssgs[index];
                return Row(
                  mainAxisAlignment: mssg.me == 1
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    DbMssgBubble(mssg: mssg)
                    // MessageBubble(
                    //   inSelectionMode: false,
                    //   dbMssg: mssg,
                    //   info: true,
                    // ),
                  ],
                );
              },
              itemCount: widget.mssgs.length),
        ],
      ),
    );
  }
}
