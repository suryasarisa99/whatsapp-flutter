import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:path/path.dart' as p;

class AudioMssgBubble extends StatefulWidget {
  const AudioMssgBubble({super.key, required this.mssg});

  final DbMssgVideoFile mssg;

  @override
  State<AudioMssgBubble> createState() => _AudioMssgBubbleState();
}

class _AudioMssgBubbleState extends State<AudioMssgBubble> {
  @override
  Widget build(BuildContext context) {
    final path = p.join(whatsappPath, widget.mssg.file);
    return SizedBox(
      height: 60,
      width: 250,
      child: InkWell(
          onTap: () async {
            debugPrint(path);
            final result = await OpenFile.open(path, type: "audio/*");

            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Could not open file: ${result.message}')),
              );
            }
          },
          child: Row(
            children: [
              SizedBox(width: 8),
              Icon(
                Icons.play_arrow,
                size: 50,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Audio Message",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  Text(
                      "${widget.mssg.duration} sec   ${(widget.mssg.length / 1024).toStringAsFixed(0)} kb",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ))
                ],
              )
            ],
          )),
    );
  }
}
