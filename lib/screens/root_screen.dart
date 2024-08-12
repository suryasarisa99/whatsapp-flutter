import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:root_access/root_access.dart';
import 'dart:async';
import 'package:process_run/shell.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _rootStatus = false;
  String _commandOutput = '';
  List<DbChat> chatList = [];

  @override
  void initState() {
    super.initState();
    test();
    initRootRequest();
  }

  Future<void> initRootRequest() async {
    bool rootStatus = await RootAccess.requestRootAccess;
    setState(() {
      _rootStatus = rootStatus;
    });
  }

  Future<void> copyCmd() async {
    const sourcePath = "/data/data/com.whatsapp/databases/";
    const destPath = "/data/data/com.example.whatsapp_chat/databases/";
    const files = [
      "msgstore.db",
      "msgstore.db-wal",
      "msgstore.db-shm",
      "wa.db",
      "wa.db-wal",
      "wa.db-shm",
    ];
    for (var file in files) {
      await executeCommand('su -c cp $sourcePath$file $destPath$file');
      await executeCommand('su -c chmod 777 $destPath$file');
    }
  }

  Future<void> executeCommand(String command) async {
    if (_rootStatus) {
      var shell = Shell();
      try {
        var result = await shell.run(command);
        debugPrint(result.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Root access not granted");
    }
  }

  void test() async {
    var d = await getApplicationDocumentsDirectory();
    print(d.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Root Access Example'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            debugPrint("clicked");
            // executeCommand(
            //     "rm -rf /data/data/com.example.whatsapp_chat/databases/*");
            // debugPrint("deleted done");

            // await copyCmd();
            // debugPrint("copied done");

            // DatabaseHelper.instance.test1();

            DatabaseHelper.instance.getChatList().then((chats) {
              setState(() {
                chatList = chats;
              });
            });
          },
          label: Text("load")),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final item = chatList[index];
          return ListTile(
            leading: CircleAvatar(
                radius: 25,
                child: Icon(
                  Icons.person,
                  size: 25,
                )),
            trailing: Text(item.date.toString(),
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
    );
  }
}
