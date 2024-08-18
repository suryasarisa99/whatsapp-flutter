import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
import 'package:whatsapp_chat/components/chat_input.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:path/path.dart' as p;
import 'package:whatsapp_chat/screens/chat_screen/components.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.data});

  Messages data;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int direction = widget.data.direction;

  // final ScrollController _scrollController = ScrollController();
  bool scrollDirection = true; // bottom by default
  bool isOnTop = false;
  final ItemScrollController _scrollController = ItemScrollController();
  final _scrollOffsetController = ScrollOffsetController();
  bool searchMode = false;
  FocusNode searchNode = FocusNode();
  var _searchQueryController = TextEditingController();

  List<int> searchIndexes = [];
  int currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();

    // focu node (search node) on unfocus

    // searchNode.addListener(() {
    //   if (!searchNode.hasFocus) {
    //     // currentSearchIndex = -1;
    //   }
    // });
  }

  void handleSearch() {
    final List<int> _searchResults;
    // var mssgsfuzzy = Fuzzy(widget.data.messages,
    //     options: FuzzyOptions(keys: [
    //       WeightedKey(
    //           name: "mssg",
    //           getter: (Message x) => x.mssg,
    //           weight: 1)
    //     ]));
    // _searchResults = mssgsfuzzy
    //     .search(_searchQueryController.text)
    //     .map((e) => e.item.index)
    //     .toList();

    _searchResults = widget.data.messages
        .where(
            (e) => e.mssg.toLowerCase().contains(_searchQueryController.text))
        .map((e) => e.index)
        .toList();
    setState(() {
      if (_searchResults.isNotEmpty) {
        searchIndexes = _searchResults;
        currentSearchIndex = 0;
        scrollToIndex(searchIndexes[currentSearchIndex]);
      }
    });
  }

  void handleSearchCancel() {
    setState(() {
      searchMode = false;
      currentSearchIndex = -1;
      searchIndexes = [];
    });
    _searchQueryController.text = "";
  }

  void scrollToIndex(int index) {
    _scrollController.scrollTo(
      index: index,
      duration:
          Duration(milliseconds: 500), // Adjust animation duration as needed
      curve: Curves.easeInOut, // Customize scrolling animation
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double patternOpacity = isDark ? 0.13 : 0.8;

    return PopScope(
      canPop: !searchMode,
      onPopInvoked: (x) {
        print("popup Scope: ${x}");
        if (searchMode) {
          handleSearchCancel();
        }
      },
      child: Scaffold(
        appBar: searchMode
            ? AppBar(
                automaticallyImplyLeading: false,
                title: CupertinoTextField(
                  placeholder: "Search",
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  focusNode: searchNode,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  controller: _searchQueryController,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  prefix: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                          onPressed: handleSearchCancel,
                          icon: Icon(Icons.arrow_back))),
                  onSubmitted: (_) {
                    handleSearch();
                  },
                  suffix: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (currentSearchIndex + 1 <
                                    searchIndexes.length) {
                                  currentSearchIndex++;
                                  scrollToIndex(
                                      searchIndexes[currentSearchIndex]);
                                }
                              });
                            },
                            icon: FaIcon(FontAwesomeIcons.chevronUp, size: 17)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (currentSearchIndex - 1 >= 0) {
                                  currentSearchIndex--;
                                  scrollToIndex(
                                      searchIndexes[currentSearchIndex]);
                                }
                              });
                            },
                            icon:
                                FaIcon(FontAwesomeIcons.chevronDown, size: 17)),
                      ],
                    ),
                  ),
                ),
              )
            : AppBar(
                // forceMaterialTransparency: true,
                toolbarHeight: kToolbarHeight + 5,
                elevation: 3.0,
                title: Row(
                  children: [
                    CircleAvatar(
                        radius: 23,
                        child: Icon(
                          Icons.person,
                          size: 30,
                        )),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.data.names[direction == 0 ? 1 : 0],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 19)),
                    ),
                  ],
                ),
                leadingWidth: 24,
                actions: [
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.videocam_outlined)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined)),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(
                            95,
                            50,
                            5,
                            100,
                          ),
                          items: [
                            CustomMenuItem(
                                onTap: () {
                                  setState(() {
                                    direction = (direction + 1) % 2;
                                    widget.data.direction = direction;
                                  });
                                },
                                icon: Icons.swap_horiz,
                                title: "Swap"),
                            CustomMenuItem(
                                onTap: () async {
                                  setState(() {
                                    isOnTop = !isOnTop;
                                    scrollToIndex(isOnTop
                                        ? widget.data.messages.length - 1
                                        : 0);
                                  });
                                },
                                icon: Icons.swap_vert,
                                title: isOnTop ? "Go Bottom" : "Go Top"),
                            CustomMenuItem(
                                onTap: () {
                                  setState(() {
                                    searchMode = true;
                                  });
                                  searchNode.requestFocus();
                                },
                                icon: Icons.search,
                                title: "Search"),
                          ]);
                    },
                  ),
                ],
              ),
        body: Stack(
          children: [
            ChatBackground(),
            Column(
              children: [
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: widget.data.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      bool isMe = widget.data.messages[index].name ==
                          widget.data.names[direction];
                      return Container(
                        color: currentSearchIndex != -1 &&
                                searchIndexes[currentSearchIndex] == index
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.5)
                            : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            ChatBubble(
                              widget.data.messages[index],
                              isMe,
                              dir: widget.data.chatDir,
                            ),
                          ],
                        ),
                      );
                    },
                    itemScrollController: _scrollController,
                    scrollOffsetController: _scrollOffsetController,
                  ),
                ),
                ChatInputField(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomMenuItem extends PopupMenuItem {
  CustomMenuItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
  }) : super(
          child: Row(children: [Icon(icon), SizedBox(width: 16), Text(title)]),
          onTap: onTap,
        );

  final String title;
  final IconData icon;
  void Function() onTap;
}

extension ColorExtensions on Color {
  Color inc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return darken(amount);
  }

  Color revInc(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return lighten(amount);
    }
    return lighten(amount);
  }

  Color dec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return lighten(amount);
  }

  Color revDec(BuildContext context, [double amount = 0.1]) {
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      return darken(amount);
    }
    return darken(amount);
  }

  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final darkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lightened =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }
}
