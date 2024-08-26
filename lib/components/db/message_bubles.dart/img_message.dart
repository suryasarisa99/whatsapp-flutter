import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:path/path.dart' as p;

class ImgMessage extends StatelessWidget {
  const ImgMessage({
    super.key,
    required this.mssg,
    required this.size,
  });

  final DbMssgImageFile mssg;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final path = p.join(whatsappPath, mssg.file);
    return InkWell(
      onTap: () {
        GoRouter.of(context).push("/image-preview", extra: mssg);
      },
      child: Hero(
        tag: path,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
            alignment: Alignment(0, -0.5),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: size.height,
                width: size.width,
                color: mycolors(
                    context,
                    mssg.me == 1
                        ? MyColors.MyInnnerChatBubble
                        : MyColors.OtherInnerChatBubble),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 12,
                      child: Text(
                        "${(mssg.length / 1024).toStringAsFixed(0)} KB",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.65),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
