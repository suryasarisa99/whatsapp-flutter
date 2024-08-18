import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class PlayerScreen extends StatefulWidget {
  final String filePath;

  const PlayerScreen({super.key, required this.filePath});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(
      File(widget.filePath),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: false,
            fullScreenByDefault: true,
            allowFullScreen: false,
            zoomAndPan: true,
            // isLive: true,
            // optionsBuilder: (context, options) async {
            //   return options.copyWith(
            //     aspectRatio: 16 / 9,
            //     showControlsOnInitialize: false,
            //     showControls: false,
            //   );
            // },

            maxScale: 2,
            showControls: true,
          );
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isInitialized
            ? Chewie(
                controller: _chewieController,
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
