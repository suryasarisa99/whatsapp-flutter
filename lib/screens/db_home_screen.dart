import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:root_access/root_access.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp_chat/components/db/chat_filters.dart';
import 'package:whatsapp_chat/components/db/chat_list_item.dart';
import 'package:whatsapp_chat/components/db/db_home_searchbar.dart';
import 'package:whatsapp_chat/components/db/dummy_search_bar.dart';
import 'package:whatsapp_chat/components/home_appbar.dart';
import 'package:whatsapp_chat/components/home_searchbar.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/main.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
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

class _RootScreenState extends ConsumerState<RootScreen> {
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
    // listen for focus input
    // focusNode.addListener(() {
    //   if (focusNode.hasFocus) {
    //     debugPrint(" <<>>>>  Search Mode on <<<>>>");
    //     ref.read(optionsProvider.notifier).set(true);
    //   } else {
    //     ref.read(optionsProvider.notifier).set(false);
    //   }
    // });

    // textController.addListener(() {
    //   debugPrint("<<>>>    inside text input controller  <<>>");

    // if (textController.text.isEmpty) {
    //   if (!queryIsEmpty) {
    //     setState(() {
    //       queryIsEmpty = true;
    //       chatList = chatListCopy;
    //     });
    //   }
    // } else {
    //   if (queryIsEmpty) {
    //     setState(() {
    //       queryIsEmpty = false;
    //     });
    //   }
    //   Fuzzy(chatListCopy,
    //       options: FuzzyOptions(keys: [
    //         WeightedKey(
    //           getter: (DbChat chat) => chat.groupName ?? "",
    //           weight: 0.5,
    //           name: "groupName",
    //         ),
    //         WeightedKey(
    //           getter: (DbChat chat) => chat.no,
    //           weight: 0.5,
    //           name: "no",
    //         ),
    //       ])).search(textController.text);
    // }
    // });
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
    final permissionstatus = await Permission.manageExternalStorage.request();
    debugPrint("Permission status: $permissionstatus");
    if (rootStatus) {
      // executeCommand("ls /data/data");
      getContacts();
      final path = p.join(await getDatabasesPath(), "msgstore.db");
      final status = await File(path).exists();
      debugPrint("File exists: $status");
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
    const whatsapp = "/data/data/com.whatsapp";
    const myapp = "/data/data/com.example.whatsapp_chat";

    const files = [
      "msgstore.db",
      "msgstore.db-wal",
      "msgstore.db-shm",
    ];

    final List<String> commands = [];
    for (var file in files) {
      String sourceFile = '$whatsapp/databases/$file';
      String destFile = '$myapp/databases/$file';
      commands.add("cp $sourceFile $destFile");
      commands.add("chmod 777 $destFile");
    }
    commands.add("cp -r $whatsapp/files/Avatars $externalDir/");
    commands.add("cp -r '$whatsapp/cache/Profile Pictures' $externalDir/");
    await executeCommandsInSubshell(commands);
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
        // var result = await shell.run("su -c -mm $command");
        var result = await shell.run(command);
        debugPrint(result.outText.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Root access not granted");
    }
  }

  void completeRefresh() async {
    final s = DateTime.now();
    DatabaseHelper.instance.disonnect();
    executeCommand("rm -rf /data/data/com.example.whatsapp_chat/databases/*");
    debugPrint("deleted done");

    await copyCmd();
    debugPrint("copied done");
    final e = DateTime.now();
    debugPrint("Time taken: ${e.difference(s).inMilliseconds}");

    refresh();
  }

  void refresh() async {
    if (_rootStatus) {
      DatabaseHelper.instance.getChatList().then((chats) async {
        if (contacts.isEmpty) {
          debugPrint("contacts empty");
          await Future.delayed(Duration(seconds: 1));
        }

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

  Future<int> executeCommandsInSubshell(List<String> commands) async {
    final process = await Process.start('su', ['-M']);

    // Write commands to the subshell
    for (var command in commands) {
      process.stdin.writeln(command);
    }
    // Add more commands as needed
    process.stdin.writeln('exit'); // Exit the subshell when done

    // Listen to stdout
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      print(data);
    });

    // Listen to stderr
    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      print('Error: $data');
    });

    final exitCode = await process.exitCode;
    print('Subshell exited with code $exitCode');
    return exitCode;
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
              // refresh();
              completeRefresh();
            },
            label: Text("load"),
            icon: FaIcon(
              FontAwesomeIcons.database,
              size: 16,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            forceMaterialTransparency: true,
            titleSpacing: 0,
            toolbarHeight: kToolbarHeight + 45,
            title: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // DbHomeSearchbar(
                  //   focusNode: focusNode,
                  //   textController: textController,
                  //   handleChange: (x) {},
                  // ),
                  InkWell(
                      onTap: () {
                        GoRouter.of(context)
                            .push('/search', extra: chatListCopy);
                      },
                      child: DummySearchBar()),
                  ChatFilters(
                      filters: filters,
                      selectedFilter: selectedFilter,
                      handleFilter: (x) {
                        setState(() {
                          selectedFilter = x;
                        });
                      })
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              return DbChatListItem(item: chatList[index]);
            },
            itemCount: chatList.length,
          )
        ],
      ),
    );
  }
}
