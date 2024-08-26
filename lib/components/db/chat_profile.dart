import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/main.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class DbChatProfileScreen extends StatefulWidget {
  const DbChatProfileScreen({super.key, required this.chat});
  final DbChat chat;

  @override
  State<DbChatProfileScreen> createState() => _DbChatProfileScreenState();
}

class _DbChatProfileScreenState extends State<DbChatProfileScreen> {
  List<Map<String, int>> mediaCount = [];

  @override
  void initState() {
    DatabaseHelper.instance.getMediaCount(widget.chat.cid).then((result) {
      // setState(() {
      //   mediaCount = result;
      // });
      groupSimilarMessageItems(result);
    });
  }

  void groupSimilarMessageItems(List<Map<String, int>> types) {
    const x = {
      14: 4,
      10: 90,
      43: 42,
    };

    final Map<int, int> groupedResults = {};

    for (var item in types) {
      int type = item['type']!;
      int count = item['count']!;

      if (x.containsKey(type)) {
        int newType = x[type]!;
        if (groupedResults.containsKey(newType)) {
          groupedResults[newType] = groupedResults[newType]! + count;
        } else {
          groupedResults[newType] = count;
        }
      } else {
        if (groupedResults.containsKey(type)) {
          groupedResults[type] = groupedResults[type]! + count;
        } else {
          groupedResults[type] = count;
        }
      }
    }

    // Convert the grouped results back to a list of maps
    final List<Map<String, int>> groupedList =
        groupedResults.entries.map((entry) {
      return {'type': entry.key, 'count': entry.value};
    }).toList();

    // Update the mediaCount with the grouped results
    setState(() {
      mediaCount = groupedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          snap: false,
          // title: Text(widget.chat.groupName ?? ""),
          expandedHeight: 180,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.only(top: 35.0),
              child: Center(
                child: Container(
                  height: 150,
                  width: 150,
                  child: Hero(
                    tag: "profile-pic-${widget.chat.rawJid}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.file(
                        File("$externalDir/Avatars/${widget.chat.rawJid}.j"),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 100,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // title: Text(widget.chat.groupName ?? "",
            //     style: TextStyle(fontSize: 18)),
          ),
        ),
        // SliverToBoxAdapter(
        //   child: Column(
        //       children: mediaCount.map((e) {
        //     final item = messgeTypeMap[e['type']];
        //     return ListTile(
        //       onTap: () async {
        //         final data = await DatabaseHelper.instance
        //             .getMssgsOfType(widget.chat.cid, e['type']!);
        //         GoRouter.of(context).push("/messages-preview", extra: data);
        //       },
        //       leading: Icon(
        //         item?.icon ?? Icons.abc,
        //         size: 16,
        //       ),
        //       title: Text(
        //           "${messgeTypeMap[e['type']]?.label ?? e['type']} :\t${e['count']}"),
        //     );
        //   }).toList()),
        // )

        SliverToBoxAdapter(
          child: SizedBox(
            height: 20,
          ),
        ),

        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: 1.35),
          itemBuilder: (context, index) {
            final item = mediaCount[index];
            final itemInfo = messgeTypeMap[item['type']];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final data = await DatabaseHelper.instance
                      .getMssgsOfType(widget.chat.cid, item['type']!);
                  GoRouter.of(context).push("/messages-preview", extra: data);
                },
                child: Center(
                  child: Container(
                      width: 78,
                      padding: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          itemInfo?.icon != null
                              ? Icon(
                                  itemInfo?.icon,
                                  size: 18,
                                  // size: itemInfo?.label == "Gifs" ? 16 : 16,
                                )
                              : Text("${item['type']}"),
                          SizedBox(height: 5),
                          Text("${item['count']}")
                        ],
                      )),
                ),
              ),
            );
          },
          itemCount: mediaCount.length,
        )
      ],
    ));
  }
}
