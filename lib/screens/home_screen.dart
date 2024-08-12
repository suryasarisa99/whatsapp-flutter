import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

SharedPreferences? prefs;
Directory chatsDir = Directory("");
String chatsPath = "";

class _HomeScreenState extends State<HomeScreen> {
  List<SavedMessageItems> savedMessages = [];

  final FocusNode focusNode = FocusNode();
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _requestPermissions();

    // getApplicationDocumentsDirectory().then((d) {
    getExternalStorageDirectory().then((d) {
      print(d!.path);
      chatsPath = p.join(d!.path, "chats");
      print(chatsPath);
      chatsDir = Directory(chatsPath);
    });

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      final rawtext = prefs!.getString("chats");
      final rawData = jsonDecode(rawtext ?? "[]") as List;
      setState(() {
        savedMessages = rawData
            .map(
                (e) => SavedMessageItems.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permissions are granted, proceed with opening the file
    } else {
      // Permissions are denied, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to open files')),
      );

      // Request permissions again
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.request().isGranted) {
      // MANAGE_EXTERNAL_STORAGE permission granted
    } else {
      // MANAGE_EXTERNAL_STORAGE permission denied, guide the user to the settings page
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sbColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.lighten(0.05)
        : Theme.of(context).colorScheme.primaryContainer.lighten(0.06);
    debugPrint(sbColor.toString());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('WhatsApp',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary,
                fontSize: 26)),
        actions: const [
          Icon(Icons.qr_code_scanner_outlined),
          SizedBox(width: 22),
          Icon(Icons.camera_alt_outlined),
          SizedBox(width: 22),
          Icon(Icons.more_vert),
          SizedBox(
            width: 10,
          )
        ],
      ),
      floatingActionButton: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
              onPressed: () {
                handleFilePickAndPareMssgs(chatsPath, (Messages messages) {
                  final savedMssgItem = messages.toSavedMessageItem();
                  setState(() {
                    savedMessages.add(savedMssgItem);
                    prefs!.setString(
                        "chats",
                        jsonEncode(
                            savedMessages.map((e) => e.toJson()).toList()));
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("add"))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CupertinoTextField(
              placeholder: "Ask Meta Ai or Search",
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: sbColor,
              ),
              prefix: const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 8, top: 13, bottom: 13),
                child: Icon(Icons.search),
              ),
              focusNode: focusNode,
              onTapOutside: (x) {
                focusNode.unfocus();
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: savedMessages.length,
              itemBuilder: (context, index) {
                final item = savedMessages[index];
                return ListTile(
                  leading: CircleAvatar(
                      radius: 25,
                      child: Icon(
                        Icons.person,
                        size: 25,
                      )),
                  title: Text(item.names[item.direction == 0 ? 1 : 0],
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                  subtitle: Text(item.lastMssg ?? "",
                      overflow: TextOverflow.ellipsis),
                  trailing: Text(item.lastMssgTime ?? "",
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6))),
                  onLongPress: () async {
                    // delete chat
                    if (item.isFolder) {
                      final path = p.join(chatsPath, item.chatId);
                      final dir = await Directory(path);
                      dir.deleteSync(recursive: true);
                    } else {
                      final file =
                          File(p.join(chatsPath, "${item.chatId}.json"));
                      file.deleteSync();
                    }
                    setState(() {
                      savedMessages.removeAt(index);
                      prefs!.setString(
                          "chats",
                          jsonEncode(
                              savedMessages.map((e) => e.toJson()).toList()));
                    });
                  },
                  onTap: () async {
                    late final File chatFile;
                    Directory? chatDir;
                    if (item.isFolder) {
                      final chatPath = p.join(chatsPath, item.chatId);
                      chatDir = Directory(chatPath);
                      chatFile = File(p.join(chatPath, "chat.json"));
                    } else {
                      chatFile = File(p.join(chatsPath, "${item.chatId}.json"));
                    }
                    final text = await chatFile.readAsString();
                    final messages =
                        Messages.messagesFromJson(jsonDecode(text) as List);
                    GoRouter.of(context).push("/chat",
                        extra: Messages(
                          messages: messages,
                          names: item.names,
                          chatDir: chatDir,
                          isFolder: item.isFolder,
                          chatId: item.chatId,
                          direction: item.direction,
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// group message is about grouping multiple message at a some close time
List<Message> groupMessages(List<Message> messages) {
  List<Message> groupedMessages = [];
  var prvStatus = false;
  // @todo: temporary add -1 to avoid out of index error
  for (int i = 0; i < messages.length - 1; i++) {
    final Message currentMessage = messages[i];
    final Message nextMessage = messages[i + 1];

    // final c1 = compareMessage(currentMessage, previousMessage);
    final c1 = prvStatus;
    final c2 = compareMessage(currentMessage, nextMessage);
    prvStatus = c2;

    if (c1 && c2) {
      // middle message
      groupedMessages.add(currentMessage.copyWith(mssgGroupType: 2));
    } else if (c1) {
      // last message
      groupedMessages.add(currentMessage.copyWith(mssgGroupType: 3));
    } else if (c2) {
      // first message
      groupedMessages.add(currentMessage.copyWith(mssgGroupType: 1));
    } else {
      // normal message
      groupedMessages.add(currentMessage.copyWith(mssgGroupType: 0));
    }
  }
  return groupedMessages;
}

bool compareMessage(Message? a, Message? b) {
  if (a == null || b == null) return false;
  const maximumTimeDifference = Duration(minutes: 1);
  final DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm a", 'en_US');
  final String aDateTimeString = "${a.date} ${a.time}"
      .replaceAll('\u202F', ' ')
      .replaceAll('\u00A0', ' ')
      .trim()
      .toUpperCase(); // Convert to uppercase
  final String bDateTimeString = "${b.date} ${b.time}"
      .replaceAll('\u202F', ' ')
      .replaceAll('\u00A0', ' ')
      .trim()
      .toUpperCase(); //

  final DateTime aDateTime = dateFormat.parse(aDateTimeString);
  final DateTime bDateTime = dateFormat.parse(bDateTimeString);

  return a.name == b.name &&
      aDateTime.difference(bDateTime).abs() < maximumTimeDifference;
}

const List<List<BorderRadius>> mssgBorderRadius = [
  // for right side mssg
  [
    BorderRadius.only(
      topRight: Radius.circular(16), // #
      bottomRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      topLeft: Radius.circular(16),
    ),
    BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
    BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
    BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
  ],
  // for left side mssg
  [
    BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    BorderRadius.only(
      topRight: Radius.circular(16),
      topLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
    BorderRadius.only(
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
    BorderRadius.only(
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    ),
  ]
];
