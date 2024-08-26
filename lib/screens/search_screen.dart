import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:whatsapp_chat/components/db/chat_list_item.dart';
import 'package:whatsapp_chat/components/db/db_home_searchbar.dart';
import 'package:whatsapp_chat/components/db/dummy_search_bar.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.data});
  final List<DbChat> data;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final focusNode = FocusNode();
  final textController = TextEditingController();
  late List<DbChat> chats = widget.data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 280));
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: DbHomeSearchbar(
              focusNode: focusNode,
              textController: textController,
              handleChange: (text) {
                final result = Fuzzy(widget.data,
                    options: FuzzyOptions(keys: [
                      WeightedKey(
                        getter: (DbChat chat) => chat.groupName ?? "",
                        weight: 0.5,
                        name: "groupName",
                      ),
                      WeightedKey(
                        getter: (DbChat chat) => chat.no,
                        weight: 0.5,
                        name: "no",
                      ),
                    ])).search(textController.text).map((e) => e.item).toList();
                setState(() {
                  chats = result;
                });
              }),
          titleSpacing: 0,
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return DbChatListItem(item: chats[index]);
          },
          itemCount: chats.length,
        ));
  }
}
