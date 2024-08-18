import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:root_access/root_access.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp_chat/components/home_appbar.dart';
import 'package:whatsapp_chat/components/home_searchbar.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

final formatDate = DateFormat('d/M h:m a');
final onlyDateformat = DateFormat('d/M');

String toDateStr(int? d) {
  if (d == null) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(d);
  if (date.day == DateTime.now().day) return "Today";
  if (date.day == DateTime.now().subtract(Duration(days: 1)).day) {
    return "Yesterday";
  } else {
    return onlyDateformat.format(date);
  }
}

class _RootScreenState extends State<RootScreen> {
  bool _rootStatus = false;
  String _commandOutput = '';
  List<DbChat> chatList = [];
  List<DbChat> chatListCopy = [];
  List<DbChat> achivedChats = [];
  List<Contact> contacts = [];
  int selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void replaceWhatsappDatabase() async {
    const whatsappPath = "/data/data/com.whatsapp/databases/";
    const destPath = "/data/data/com.example.whatsapp_chat/databases/";
    const files = [
      "msgstore.db",
      "msgstore.db-wal",
      "msgstore.db-shm",
    ];
    for (var f in files) {
      await executeCommand("rm  $whatsappPath$f");
      await executeCommand("cp $destPath$f $whatsappPath$f");
      await executeCommand("chmod 771 $whatsappPath$f");
    }
    print("replace done");
  }

  Future<void> getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      print("contacts got");
    } else {
      debugPrint("Permission not granted");
    }
  }

  Future<void> initial() async {
    bool rootStatus = await RootAccess.requestRootAccess;
    setState(() {
      _rootStatus = rootStatus;
    });
    if (rootStatus) {
      // executeCommand("ls /data/data");
      getContacts();
      final path = p.join(await getDatabasesPath(), "msgstore.db");
      final status = await File(path).exists();
      if (status) {
        refresh();
      } else {
        completeRefresh();
      }
    } else {
      debugPrint("Root access not granted 1");
    }
  }

  Future<void> copyCmd() async {
    const sourcePath = "/data/data/com.whatsapp/databases/";
    const destPath = "/data/data/com.example.whatsapp_chat/databases/";

    const files = [
      "msgstore.db",
      "msgstore.db-wal",
      "msgstore.db-shm",
      // "wa.db",
      // "wa.db-wal",
      // "wa.db-shm",
    ];
    for (var file in files) {
      String sourceFile = '$sourcePath$file';
      // debugPrint(await getPermissions(sourceFile));
      await executeCommand('cp $sourceFile $destPath$file');
      await executeCommand('chmod 777 $destPath$file');
    }
  }

  Future<String> getPermissions(String filePath) async {
    var result = await Process.run('stat', ['-c', '%a', filePath]);
    if (result.exitCode == 0) {
      debugPrint("Permissions: ${result.stdout}");
      debugPrint("Permissions: ${result.outText}");
      return result.stdout.trim();
    } else {
      debugPrint("Error getting permissions: ${result.stderr}");
      return '';
    }
  }

  Future<void> executeCommand(String command) async {
    if (_rootStatus) {
      var shell = Shell();
      try {
        var result = await shell.run("su -c $command");
        debugPrint(result.outText.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Root access not granted");
    }
  }

  void completeRefresh() async {
    executeCommand("rm -rf /data/data/com.example.whatsapp_chat/databases/*");
    debugPrint("deleted done");

    await copyCmd();
    debugPrint("copied done");

    refresh();
  }

  void refresh() async {
    if (_rootStatus) {
      debugPrint("Root status: ${_rootStatus}");
      // executeCommand("ls /data");
      // debugPrint("done");

      // return;
      DatabaseHelper.instance.getChatList().then((chats) async {
        if (contacts.isEmpty) {
          debugPrint("contacts empty");
          await Future.delayed(Duration(seconds: 1));
        }

        debugPrint("contacts not empty");

        final allChats = <DbChat>[];
        final archived = <DbChat>[];

        for (var chat in chats) {
          if (chat.archived == 0) {
            allChats.add(chat);
          } else if (chat.archived == 1) {
            archived.add(chat);
          }
        }
        final allChatsWithContacts = allChats.map((e) {
          if (e.ps == null || e.ps == 0) {
            final contact = contacts.firstWhereOrNull((element) {
              if (element.phones.isEmpty) return false;

              final cleaned =
                  element.phones.first.normalizedNumber.replaceFirst("+", "");
              return cleaned == e.no;
            });
            if (contact == null) return e;
            debugPrint("contact: ${contact.displayName}");
            return e.copyWith(groupName: contact.displayName);
          }
          return e;
        }).toList();

        setState(() {
          chatList = allChatsWithContacts;
          achivedChats = archived;
          chatListCopy = [...allChatsWithContacts];
        });
      });
    } else {
      debugPrint("Not Rooted");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {
        'title': "All",
        'handler': () {
          setState(() {
            chatList = chatListCopy;
          });
        }
      },
      {
        'title': "Unread",
        'handler': () {
          setState(() {
            chatList =
                chatListCopy.where((element) => element.umc != 0).toList();
          });
        }
      },
      {
        'title': "Individual",
        'handler': () {
          setState(() {
            chatList =
                chatListCopy.where((element) => element.ps == 0).toList();
          });
        }
      },
      {
        'title': "Groups",
        'handler': () {
          setState(() {
            chatList =
                chatListCopy.where((element) => element.ps != 0).toList();
          });
        }
      },
      {
        'title': "Archived",
        'handler': () {
          setState(() {
            chatList = achivedChats;
          });
        }
      },
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomeAppbar(),
      floatingActionButton: InkWell(
        onLongPress: () {
          setState(() {
            chatList = [];
          });
          completeRefresh();
        },
        child: SizedBox(
          height: 45,
          child: FloatingActionButton.extended(
            onPressed: () async {
              setState(() {
                chatList = [];
              });
              refresh();
              // completeRefresh();
            },
            label: Text("load"),
            icon: FaIcon(
              FontAwesomeIcons.database,
              size: 16,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          HomeSearchbar(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 8),
              child: Row(
                children: filters.map((e) {
                  if (filters.indexOf(e) == selectedFilter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          (e['handler']! as void Function())();
                          setState(() {
                            selectedFilter = filters.indexOf(e);
                          });
                        },
                        child: Container(
                          constraints: BoxConstraints(minWidth: 60),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            e['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6)),
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        (e['handler']! as void Function())();
                        setState(() {
                          selectedFilter = filters.indexOf(e);
                        });
                      },
                      child: Container(
                        constraints: BoxConstraints(minWidth: 60),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .lighten(0.03),
                            borderRadius: BorderRadius.circular(18)),
                        child: Text(
                          e['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final item = chatList[index];
                return ListTile(
                  onTap: () {
                    debugPrint("get chat of ${item.no}");
                    DatabaseHelper.instance.getChat(item.cid).then((mssgs) {
                      GoRouter.of(context).push("/dbchat",
                          extra: DbMssgs(mssgs: mssgs, chat: item));
                    });
                  },
                  leading: CircleAvatar(
                      radius: 25,
                      child: Icon(
                        Icons.person,
                        size: 25,
                      )),
                  trailing: item.umc != 0
                      ? CircleAvatar(
                          radius: 14,
                          child: Text(item.umc.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6))),
                        )
                      : Text(toDateStr(item.date),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6))),
                  title: Text(
                    chatList[index].groupName ?? chatList[index].no,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chatList[index].mssg ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
