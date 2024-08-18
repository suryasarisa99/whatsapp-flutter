import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class FilePreviewNew extends StatefulWidget {
  const FilePreviewNew({
    super.key,
    required this.filePath,
    required this.isMe,
    required this.type,
  });

  final String filePath;
  final int type;
  final bool isMe;

  @override
  State<FilePreviewNew> createState() => _FilePreviewNewState();
}

class _FilePreviewNewState extends State<FilePreviewNew> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (p.extension(widget.filePath) == ".mp4") {
      _controller = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
          print("video playing");
        });
    }
  }

  Future<Widget> readVcfFile(Size size) async {
    var text = utf8.decode(await File(widget.filePath!).readAsBytes(),
        allowMalformed: true);
    var contact = Contact.fromVCard(text);
    return SizedBox(
      width: size.width * 0.65,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: contact.photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.memory(
                    Uint8List.fromList(contact.photo!),
                  ))
              : Text(contact.displayName[0]),
        ),
        title: Text(contact.displayName),
        subtitle: Text(contact.phones.first.number.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String ext = p.extension(widget.filePath);
    debugPrint(ext);
    if ((ext == ".jpg" || ext == ".jpeg" || ext == '.png' || ext == '.webp')) {
      return SizedBox(
        width: size.width * 0.7,
        height: size.width * 0.75,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16 - 8),
            child: Image.file(
              File(widget.filePath),
              fit: BoxFit.cover,
              alignment: Alignment(0, -0.5),
            )),
      );
    }

    if (ext == '.vcf') {
      return FutureBuilder<Widget>(
        future: readVcfFile(size),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }
          return SizedBox(
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    if (extensions.keys.contains(ext)) {
      double rightMssgInnrDarkness =
          Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.05;
      return Container(
        width: size.width * 0.68,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          // color:
          // Theme.of(context).colorScheme.primaryContainer.dec(context, 0.01),
          color: widget.isMe
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .revDec(context, 0.01)

              // inc : 0.01
              : Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .dec(context, rightMssgInnrDarkness),
          // .revInc(context, 0.12), // inc 0.12, 0.03
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/' + extensions[ext]!,
              height: 70,
              width: 55,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                p.basename(widget.filePath),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      );
    }

    if (ext == ".mp4") {
      return _isInitialized
          ? InkWell(
              onTap: () {
                GoRouter.of(context).push("/video", extra: widget.filePath);
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(
                  _controller,
                ),
              ),
            )
          : Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      child: Text("File: ${widget.filePath}"),
    );
  }
}

const extensions = {
  '.bin': 'binary.png',
  '.binary': 'binary.png',
  '.css': 'css.png',
  '.doc': 'doc.png',
  '.docx': 'doc.png',
  '.document': 'doc.png',
  '.html': 'html.png',
  '.java': 'java.png',
  '.js': 'js.png',
  '.json': 'json.png',
  // '.key': 'key.png',
  // 'md.png': 'md.png',
  '.pdf': 'pdf.png',
  '.ppt': 'ppt.png',
  '.pptx': 'ppt.png',
  '.txt': 'txt-l1.png',
  '.xls': 'xls.png',
  '.xlsx': 'xls.png',
  // '.xml': 'xml.png',
  '.py': 'python.png',
  '.rar': 'rar.png',
  '.torrent': 'torrent.png',
  'yaml': 'yaml.png',
  '.zip': 'zip.png',
};
