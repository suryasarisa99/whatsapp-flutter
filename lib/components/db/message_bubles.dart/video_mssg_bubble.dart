import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:path/path.dart' as p;

class VideoMssgBubble extends StatefulWidget {
  const VideoMssgBubble({super.key, required this.mssg, required this.size});
  final DbMssgVideoFile mssg;
  final Size size;

  @override
  State<VideoMssgBubble> createState() => _VideoMssgBubbleState();
}

class _VideoMssgBubbleState extends State<VideoMssgBubble> {
  late VideoPlayerController _controller;
  bool fileExists = true;

  @override
  void initState() {
    super.initState();
    final path = p.join(whatsappPath, widget.mssg.file);
    final file = File(path);
    final status = file.existsSync();
    if (!status) {
      setState(() {
        fileExists = false;
      });
      return;
    }
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(
            () {}); // Ensure the first frame is shown after the video is initialized
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("Video::::   H: ${widget.mssg.height} W: ${widget.mssg.width}");

    final path = p.join(whatsappPath, widget.mssg.file);
    return !fileExists
        ? SizedBox(
            height: widget.size.height,
            width: widget.size.width,
            child: Center(
              child: Icon(FontAwesomeIcons.videoSlash),
            ),
          )
        : InkWell(
            onTap: () {
              GoRouter.of(context).push("/video", extra: path);
            },
            child: _controller.value.isInitialized
                ? SizedBox(
                    height: widget.size.height,
                    width: widget.size.width,
                    // aspectRatio: _controller.value.aspectRatio,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: VideoPlayer(_controller)),
                  )
                : Center(child: CircularProgressIndicator()),
          );
  }
}
