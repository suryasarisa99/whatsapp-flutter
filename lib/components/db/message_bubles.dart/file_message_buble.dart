import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:path/path.dart' as p;
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/utils/handle.dart';

class FileMessageBuble extends ConsumerWidget {
  final DbMssgDocumentFile mssg;

  const FileMessageBuble({Key? key, required this.mssg}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    String ext = p.extension(mssg.file ?? mssg.name ?? "");
    final isMe = mssg.me == 1;
    final path = p.join(whatsappPath, mssg.file ?? mssg.name ?? "");
    return InkWell(
      onTap: mssg.file != null
          ? () async {
              if (mssg.file!.contains("WhatsApp Chat") &&
                  (mssg.file!.endsWith(".txt") ||
                      mssg.file!.endsWith(".zip"))) {
                handleData(null, path, mssg.file, (Messages messages) {
                  final savedMssgItem = messages.toSavedMessageItem();
                  ref.read(savedChatsProvider.notifier).addChat(savedMssgItem);
                  GoRouter.of(context).push("/chat", extra: messages);
                });
                return;
              }

              final result = await OpenFile.open(path, type: mssg.mime);

              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Could not open file: ${result.message}')),
                );
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: mycolors(
              context,
              isMe
                  ? MyColors.MyInnnerChatBubble
                  : MyColors.OtherInnerChatBubble),
          borderRadius: BorderRadius.circular(12),
        ),
        width: size.width * 0.68,
        child: Row(
          children: [
            Image.asset(
              'assets/icons/' + (extensions[ext] ?? extensions["."]!),
              height: 60,
              width: 45,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.basename(mssg.file ?? mssg.name ?? ""),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                      "${(mssg.length / 1024).toStringAsFixed(0)} KB   ${mssg.count} Pages",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.65)))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
