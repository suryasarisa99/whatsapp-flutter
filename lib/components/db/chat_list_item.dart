import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsapp_chat/main.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/screens/db_home_screen.dart';

class DbChatListItem extends StatefulWidget {
  const DbChatListItem({super.key, required this.item});

  final DbChat item;

  @override
  State<DbChatListItem> createState() => _DbChatListItemState();
}

class _DbChatListItemState extends State<DbChatListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        debugPrint("get chat of ${widget.item.no}");
        DatabaseHelper.instance.getMessages(widget.item.cid).then((mssgs) {
          GoRouter.of(context)
              .push("/dbchat", extra: DbMssgs(mssgs: mssgs, chat: widget.item));
        });
      },
      leading: InkWell(
        onTap: () {
          final pic = "$externalDir/Profile Pictures/${widget.item.no}.jpg";
          File picFile = File(pic);
          final hdpicExist = picFile.existsSync();
          if (!hdpicExist) {
            picFile = File("$externalDir/Avatars/${widget.item.rawJid}.j");
          }
          showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: Material(
                  child: Hero(
                    tag: "profile-pic-${widget.item.rawJid}",
                    child: Image.file(
                      picFile,
                      height: hdpicExist ? 350 : 200,
                      width: hdpicExist ? 350 : 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Hero(
          tag: "profile-pic-${widget.item.rawJid}",
          child: CircleAvatar(
            radius: 25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.file(
                File("$externalDir/Avatars/${widget.item.rawJid}.j"),
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
        ),
      ),
      trailing: widget.item.umc != 0
          ? CircleAvatar(
              radius: 14,
              child: Text(widget.item.umc.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6))),
            )
          : Text(toDateStr(widget.item.date),
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6))),
      title: Text(
        // (widget.item.groupName ?? widget.item.no) + " ${widget.item.cid}",
        (widget.item.groupName ?? widget.item.no),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.item.mssg ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
