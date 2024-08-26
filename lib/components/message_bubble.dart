import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_chat/components/file_preview.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';
import 'package:path/path.dart' as p;

class MessageBubble extends ConsumerWidget {
  final Message? mssg;
  final DbMssg? dbMssg;
  final bool? isme;
  final Directory? dir;
  final bool inSelectionMode;
  final bool info;

  const MessageBubble({
    required this.inSelectionMode,
    super.key,
    // Export Mssg
    this.mssg,
    this.isme,
    this.dir,
    // DbMssg
    this.dbMssg,
    this.info = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDb = dbMssg != null;
    final size = MediaQuery.of(context).size;
    final isMe = mssg != null
        ? isme!
        : dbMssg!.me == 1
            ? true
            : false;
    final String? file = mssg?.file ?? dbMssg?.text;
    String? ext = file != null ? p.extension(file) : null;
    String? message = mssg?.mssg ?? dbMssg?.text;
    String? filepath = file != null
        ? p.join(
            isDb
                ? "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp"
                : dir!.path,
            file)
        : null;
    print(" file: ${file}  ");

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
        minHeight: 20,
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
      // deleted message
      child: dbMssg?.type == 15
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FaIcon(FontAwesomeIcons.ban).icon,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "This message was deleted",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (filepath != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(16 - 8 - 2),
                    onTap: inSelectionMode
                        ? null
                        : () async {
                            if (file!.contains("WhatsApp Chat")) {
                              handleData(null, filepath!, file!,
                                  (Messages messages) {
                                final savedMssgItem =
                                    messages.toSavedMessageItem();
                                ref
                                    .read(savedChatsProvider.notifier)
                                    .addChat(savedMssgItem);
                                GoRouter.of(context)
                                    .push("/chat", extra: messages);
                              });
                              return;
                            }
                            final result = await OpenFile.open(filepath);
                            if (result.type != ResultType.done) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Could not open file: ${result.message}')),
                              );
                            }
                          },
                    child: DbFilePreview(
                      type: dbMssg?.type ?? -1,
                      isMe: isMe,
                      filePath: filepath!,
                    ),
                  ),
                if (file != null && message != null && message.isNotEmpty)
                  const SizedBox(height: 8),
                if (message != null && message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Linkify(
                      onOpen: (link) async {
                        final uri = Uri.parse(link.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      // text: message + " type: ${dbMssg!.type}",
                      text: message,
                      maxLines: 16,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      linkStyle: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                if (info)
                  Text(
                      "mid: ${dbMssg!.mid} | t: ${DateTime.fromMillisecondsSinceEpoch(dbMssg!.timestamp).toString()} | me: ${isMe}")
              ],
            ),
    );
  }
}
