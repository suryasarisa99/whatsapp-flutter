import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/audio_mssg_bubble.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/delete_mssg_bubble.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/file_message_buble.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/img_message.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/poll_message.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/sticker_mssg_bubble.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/video_mssg_bubble.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

Size calcImgSize(Size size, int? height, int? width) {
  if (height == null || width == null || (height - width) == 0) {
    debugPrint("Initial Condication Either Empty or Same");
    return Size(290, 290);
  }
  final bool isVerticalImg = height > width;
  final double h = isVerticalImg ? 380 : 200;
  final double w = isVerticalImg ? size.width * 0.65 : size.width * 0.75;
  return Size(w, h);
}

Size calcVideoSize(Size size, int? height, int? width) {
  if (height == null || width == null || width - height < 50) {
    return Size(290, 290);
  }
  final bool isVertical = height > width;
  final double h = isVertical ? 380 : 300;
  final double w = isVertical ? size.width * 0.65 : size.width * 0.75;
  return Size(w, h);
}

class DbMssgBubble extends ConsumerWidget {
  final DbMssg mssg;

  const DbMssgBubble({super.key, required this.mssg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = mssg.me == 1;
    final size = MediaQuery.of(context).size;
    late final Size? mediaSize;

    if (mssg.type == 1) {
      final imgMssg = mssg as DbMssgImageFile;
      mediaSize = calcImgSize(size, imgMssg.height, imgMssg.width);
      debugPrint("Image::::   H: ${mediaSize.height} W: ${mediaSize.width}");
    } else if (mssg.type == 3) {
      final videoMssg = mssg as DbMssgVideoFile;
      mediaSize = calcVideoSize(size, videoMssg.height, videoMssg.width);
    } else {
      mediaSize = null;
    }

    return mssg.type == 20
        ? StickerMssgBubble(mssg: mssg as DbMssgImageFile)
        : Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            constraints: BoxConstraints(
              minWidth: 50,
              minHeight: 20,
              maxWidth: mediaSize != null
                  ? mediaSize.width
                  : mssg.type == 9
                      ? size.width * 0.7
                      : size.width * 0.8,
            ),
            decoration: BoxDecoration(
              // color: const Color.fromARGB(255, 50, 51, 87),
              color: mycolors(
                  context,
                  mssg.me == 1
                      ? MyColors.MyChatBubble
                      : MyColors.OtherChatBubble),
              borderRadius: BorderRadius.only(
                topRight: !isMe
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
                bottomRight: const Radius.circular(16),
                bottomLeft: const Radius.circular(16),
                topLeft:
                    isMe ? const Radius.circular(16) : const Radius.circular(0),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 0.01,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: mssg.type == 15
                ? DeleteMssgBubble()
                : mssg.type == 66
                    ? PollMssgBubble(dbMssgPoll: mssg as DbMssgPoll)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mssg.type == 1) ...[
                            ImgMessage(
                                mssg: mssg as DbMssgImageFile,
                                size: mediaSize!),
                            if (mssg.text != null && mssg.text!.isNotEmpty)
                              const SizedBox(height: 4),
                          ],
                          if (mssg.type == 2) ...[
                            AudioMssgBubble(mssg: mssg as DbMssgVideoFile),
                            if (mssg.text != null && mssg.text!.isNotEmpty)
                              const SizedBox(height: 4),
                          ],
                          if (mssg.type == 3) ...[
                            VideoMssgBubble(
                                mssg: mssg as DbMssgVideoFile,
                                size: mediaSize!),
                            if (mssg.text != null && mssg.text!.isNotEmpty)
                              const SizedBox(height: 4),
                          ],
                          if (mssg.type == 9) ...[
                            FileMessageBuble(mssg: mssg as DbMssgDocumentFile),
                            if (mssg.text != null && mssg.text!.isNotEmpty)
                              const SizedBox(height: 4),
                          ],
                          if (mssg.text != null && mssg.text!.isNotEmpty)
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
                                text: mssg.text!,
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
                        ],
                      ));
  }
}
