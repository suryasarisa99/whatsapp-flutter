import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';

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

class ChatBubble extends ConsumerWidget {
  final Message mssg;
  final bool isMe;
  final Directory? dir;

  const ChatBubble(this.mssg, this.isMe, {super.key, this.dir});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    String? ext = mssg.file != null ? p.extension(mssg.file!) : null;
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      constraints: BoxConstraints(
        maxWidth: ext != null
            ? ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp'
                ? size.width * 0.7
                : size.width * 0.7
            : size.width * 0.8,
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
                final filepath = p.join(dir!.path, mssg.file);
                if (mssg.file!.startsWith("WhatsApp Chat")) {
                  handleData(null, filepath, mssg.file!, (Messages messages) {
                    final savedMssgItem = messages.toSavedMessageItem();
                    ref
                        .read(savedChatsProvider.notifier)
                        .addChat(savedMssgItem);
                    GoRouter.of(context).push("/chat", extra: messages);
                  });
                  return;
                }
                final result = await OpenFile.open(filepath);
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
