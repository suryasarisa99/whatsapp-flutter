import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class StickerMssgBubble extends StatelessWidget {
  const StickerMssgBubble({super.key, required this.mssg});
  final DbMssgImageFile mssg;

  @override
  Widget build(BuildContext context) {
    final path = p.join(whatsappPath, mssg.file);
    return InkWell(
      onTap: () {
        GoRouter.of(context).push("/image-preview", extra: mssg);
      },
      child: Hero(
        tag: path,
        child: Padding(
          padding: EdgeInsets.only(
              right: mssg.me == 1 ? 15 : 0,
              left: mssg.me == 1 ? 0 : 15,
              top: 5,
              bottom: 5),
          child: Image.file(File(path),
              fit: BoxFit.cover,
              height: 160,
              width: 160,
              alignment: Alignment(0, 0),
              errorBuilder: (context, error, stackTrace) {
            debugPrint("error: $error");
            return SizedBox(
              height: 160,
              width: 160,
              child: Center(child: Icon(FontAwesomeIcons.noteSticky)),
            );
          }),
        ),
      ),
    );
  }
}
