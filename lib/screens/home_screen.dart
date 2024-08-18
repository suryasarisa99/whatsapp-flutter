import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_chat/components/home_appbar.dart';
import 'package:whatsapp_chat/components/home_searchbar.dart';
import 'package:whatsapp_chat/main.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

Directory chatsDir = Directory("");
String chatsPath = "";

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _requestPermissions();

    // ref.read(savedChatsProvider.notifier).setChats(savedMessages);

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
      // setState(() {
      //   savedMessages = rawData
      //       .map(
      //           (e) => SavedMessageItems.fromJson(Map<String, dynamic>.from(e)))
      //       .toList();
      // });
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
    List<SavedMessageItems> savedMessages = ref.watch(savedChatsProvider);
    debugPrint("in build: ${savedMessages.length}");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomeAppbar(),
      floatingActionButton: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
              heroTag: "home_tag",
              onPressed: () async {
                var result = await FilePicker.platform.pickFiles(
                  allowMultiple: false, // optional
                  type: FileType.custom,
                  allowedExtensions: ['txt', 'zip'], // optional
                );
                if (result != null) {
                  var filePath = result.files.single.path!;
                  var fileName = result.files.single.name;
                  handleData(chatsPath, filePath, fileName,
                      (Messages messages) {
                    final savedMssgItem = messages.toSavedMessageItem();
                    ref
                        .read(savedChatsProvider.notifier)
                        .addChat(savedMssgItem);
                    GoRouter.of(context).push("/chat", extra: messages);
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("add"))),
      body: Column(
        children: [
          HomeSearchbar(),
          Expanded(
            child: ListView.builder(
              itemCount: savedMessages.length,
              itemBuilder: (context, index) {
                final item = savedMessages[index];
                return ListTile(
                  leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.5),
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
                    debugPrint("remove chat");
                    // delete chat
                    try {
                      if (item.isFolder) {
                        final path = p.join(chatsPath, item.chatId);
                        final dir = await Directory(path);
                        dir.deleteSync(recursive: true);
                      } else {
                        final file =
                            File(p.join(chatsPath, "${item.chatId}.json"));
                        file.deleteSync();
                      }
                    } catch (e) {
                      debugPrint("error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .darken(0.2),
                          content: Text("Error deleting chat: $e",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer)),
                          duration: const Duration(seconds: 2)));
                    }
                    ref.read(savedChatsProvider.notifier).removeChat(index);
                    // setState(() {
                    //   savedMessages.removeAt(index);
                    //   prefs!.setString(
                    //       "chats",
                    //       jsonEncode(
                    //           savedMessages.map((e) => e.toJson()).toList()));
                    // });
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
