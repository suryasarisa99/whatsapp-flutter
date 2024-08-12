import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_contacts/vcard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
// import 'package:vcf/vcf.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/screens/home_screen.dart';
import 'package:path/path.dart' as p;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.data});

  final Messages data;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int direction = widget.data.direction;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double patternOpacity = isDark ? 0.13 : 0.8;
    const svgs = [
      "bubbles.svg",
      "circuit-board.svg",
      "line-in-motion.svg",
      "topography.svg",
      "wiggle.svg",
      "random-shapes.svg"
    ];
    return Scaffold(
      appBar: AppBar(
        // forceMaterialTransparency: true,
        toolbarHeight: kToolbarHeight + 5,
        elevation: 3.0,
        title: Row(
          children: [
            CircleAvatar(
                radius: 23,
                child: Icon(
                  Icons.person,
                  size: 30,
                )),
            SizedBox(width: 12),
            Expanded(
              child: Text(widget.data.names[direction == 0 ? 1 : 0],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 19)),
            ),
          ],
        ),
        leadingWidth: 24,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam_outlined)),
          IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined)),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(
                    95,
                    50,
                    5,
                    100,
                  ),
                  items: [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz),
                          SizedBox(width: 16),
                          Text('Swap'),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          direction = (direction + 1) % 2;
                          widget.data.direction = direction;
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_downward),
                          SizedBox(width: 16),
                          Text('Go Bottom'),
                        ],
                      ),
                      onTap: () {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      },
                    ),
                  ]);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ChatBackground(),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.data.messages.length,
                  itemBuilder: (context, index) {
                    bool isMe = widget.data.messages[index].name ==
                        widget.data.names[direction];
                    return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        ChatBubble(
                          widget.data.messages[index],
                          isMe,
                          dir: widget.data.chatDir,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer)),
                    ),
                    SizedBox(width: 6),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.darken(0.12),
                      child: Icon(
                        Icons.mic,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

extension ColorExtensions on Color {
  Color inc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return darken(amount);
  }

  Color revInc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return lighten(amount);
  }

  Color dec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return lighten(amount);
  }

  Color revDec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return darken(amount);
  }

  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightened =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }
}

class ChatBubble extends StatelessWidget {
  final Message mssg;
  final bool isMe;
  final Directory? dir;

  const ChatBubble(this.mssg, this.isMe, {super.key, this.dir});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      constraints: BoxConstraints(
        maxWidth: size.width * 0.8,
        minWidth: 50,
      ),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(255, 50, 51, 87),
        color: isMe
            ? Theme.of(context).colorScheme.primaryContainer.inc(context, 0.05)
            : Theme.of(context)
                .colorScheme
                .secondaryContainer
                .dec(context, 0.08),
        // .dec(context, 0.005),
        borderRadius: BorderRadius.only(
          topRight:
              !isMe ? const Radius.circular(16) : const Radius.circular(0),
          bottomRight: const Radius.circular(16),
          bottomLeft: const Radius.circular(16),
          topLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
        ),

        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0.01,
            offset: const Offset(0, 1),
          ),
        ],
        // borderRadius: mssgBorderRadius[isMe ? 0 : 1][mssg.mssgGroupType],
      ),
      child: Column(
        children: [
          if (mssg.file != null)
            // FilePreview(
            // file: dir?.firstWhereOrNull((e) => e.name == mssg.file)),
            InkWell(
              borderRadius: BorderRadius.circular(16 - 8 - 2),
              onTap: () async {
                final result = await OpenFile.open(
                  p.join(dir!.path, mssg.file),
                );
                if (result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Could not open file: ${result.message}')),
                  );
                }
              },
              child: FilePreview(
                isMe: isMe,
                filePath: p.join(dir!.path, mssg.file),
              ),
            ),
          if (mssg.file != null && mssg.mssg.isNotEmpty)
            const SizedBox(height: 8),
          if (mssg.mssg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                mssg.mssg,
                // "${mssg.mssgGroupType} ${mssg.mssg}",
                // "file: ${mssg.file} ${mssg.mssg}",
                maxLines: 16,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  // color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FilePreview extends StatefulWidget {
  const FilePreview({super.key, required this.filePath, required this.isMe});

  final String filePath;
  final bool isMe;

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
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
    if ((ext == ".jpg" || ext == ".jpeg" || ext == '.png')) {
      return SizedBox(
        width: size.width * 0.67,
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
