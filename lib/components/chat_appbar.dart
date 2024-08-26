import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/main.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppbar({
    super.key,
    required this.title,
    this.pic,
    required this.options,
    required this.goChatProfile,
  });

  final String title;
  final String? pic;
  final Map<String, List<PopupMenuItem>> options;
  final void Function() goChatProfile;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 5);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // forceMaterialTransparency: true,
      toolbarHeight: kToolbarHeight + 5,
      elevation: 3.0,
      title: Row(
        children: [
          if (pic != null)
            Hero(
              tag: "profile-pic-$pic",
              child: CircleAvatar(
                radius: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(
                    File("$externalDir/Avatars/${pic}.j"),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 25,
                      );
                    },
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
                radius: 23,
                child: Icon(
                  Icons.person,
                  size: 30,
                )),
          SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: goChatProfile,
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 19)),
            ),
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
              position: MenuPosition,
              items: options["default"]!,
            );
          },
        ),
      ],
    );
  }
}
