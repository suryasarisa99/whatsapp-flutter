import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:path/path.dart' as p;

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key, required this.mssg});
  final DbMssgImageFile mssg;

  @override
  Widget build(BuildContext context) {
    final path = p.join(whatsappPath, mssg.file);
    return Scaffold(
      body: InteractiveViewer(
          maxScale: 10,
          child: Center(child: Hero(tag: path, child: Image.file(File(path))))),
    );
  }
}
