import 'package:flutter/services.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
import 'package:whatsapp_chat/components/chat_input.dart';
import 'package:whatsapp_chat/components/chat_search_bar.dart';
import 'package:whatsapp_chat/components/menu_item.dart';
import 'package:whatsapp_chat/components/message_bubble.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/Messages.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.data});

  Messages data;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int direction = widget.data.direction;

  // final ScrollController _scrollController = ScrollController();
  bool isOnTop = false;
  final ItemScrollController _scrollController = ItemScrollController();
  final _scrollOffsetController = ScrollOffsetController();
  bool searchMode = false;
  FocusNode searchNode = FocusNode();
  final _searchQueryController = TextEditingController();
  SearchType searchType = SearchType.Date;
  bool selectionMode = false;
  List<Message> selectedMssgs = [];

  List<int> searchIndexes = [];
  int currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  void handleSearch() {
    final List<int> _searchResults;

    if (searchType == SearchType.Fuzzy) {
      var mssgsfuzzy = Fuzzy(widget.data.messages,
          options: FuzzyOptions(keys: [
            WeightedKey(name: "mssg", getter: (Message x) => x.mssg, weight: 1)
          ]));
      _searchResults = mssgsfuzzy
          .search(_searchQueryController.text)
          .map((e) => e.item.index)
          .toList();
    } else {
      _searchResults = widget.data.messages
          .where(
              (e) => e.mssg.toLowerCase().contains(_searchQueryController.text))
          .map((e) => e.index)
          .toList();
    }
    setState(() {
      if (_searchResults.isNotEmpty) {
        searchIndexes = _searchResults;
        currentSearchIndex = 0;
        scrollToIndex(searchIndexes[currentSearchIndex]);
      } else {
        currentSearchIndex = -1;
      }
    });
  }

  void handleSearchCancel() {
    setState(() {
      searchMode = false;
      currentSearchIndex = -1;
      searchIndexes = [];
      _searchQueryController.clear();
    });
  }

  void scrollToIndex(int index) {
    _scrollController.scrollTo(
      index: index,
      duration:
          Duration(milliseconds: 100), // Adjust animation duration as needed
      curve: Curves.easeInOut, // Customize scrolling animation
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double patternOpacity = isDark ? 0.13 : 0.8;
    Map<String, List<PopupMenuItem>> options = {};

    List<PopupMenuItem> defaultOptions = [
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
              scrollToIndex(isOnTop ? widget.data.messages.length - 1 : 0);
            });
          },
          icon: Icons.swap_vert,
          title: isOnTop ? "Go Bottom" : "Go Top"),
      CustomMenuItem(
          onTap: () {
            showMenu(
                context: context,
                position: MenuPosition,
                items: options["search"]!);

            // searchNode.requestFocus();
          },
          icon: Icons.search,
          title: "Search"),
    ];

    options = {
      "default": defaultOptions,
      "search": [
        CustomMenuItem(
            onTap: () {
              setState(() {
                searchMode = true;
                searchType = SearchType.Normal;
              });
              searchNode.requestFocus();
            },
            icon: Icons.search,
            title: "Search"),
        CustomMenuItem(
            onTap: () {
              setState(() {
                searchMode = true;
                searchType = SearchType.Fuzzy;
              });
              searchNode.requestFocus();
            },
            icon: Icons.search,
            title: "Fuzzy Search"),
        CustomMenuItem(
            onTap: () {
              showDatePicker(
                context: context,
                firstDate: DateTime.now().subtract(Duration(days: 20 * 365)),
                lastDate: DateTime.now(),
                initialDate: DateTime.now(),
              );
            },
            icon: Icons.search,
            title: "Date Search"),
        CustomMenuItem(
            onTap: () {}, icon: Icons.search, title: "Advanced Search"),
      ]
    };

    return PopScope(
      canPop: !searchMode && !selectionMode,
      onPopInvoked: (x) {
        if (selectionMode) {
          setState(() {
            selectionMode = false;
            selectedMssgs = [];
          });
        } else if (searchMode) {
          handleSearchCancel();
        }
      },
      child: Scaffold(
        appBar: searchMode
            ? SearchAppBar(
                searchNode: searchNode,
                handleSearch: () {
                  if (searchType == SearchType.Normal ||
                      searchType == SearchType.Fuzzy) handleSearch();
                },
                handleSearchCancel: handleSearchCancel,
                handleNext: () {
                  setState(() {
                    if (currentSearchIndex + 1 < searchIndexes.length) {
                      scrollToIndex(searchIndexes[++currentSearchIndex]);
                    }
                  });
                },
                handlePrevious: () {
                  setState(() {
                    if (currentSearchIndex - 1 >= 0) {
                      scrollToIndex(searchIndexes[--currentSearchIndex]);
                    }
                  });
                },
                searchQueryController: _searchQueryController,
              )
            : selectionMode
                ? AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                        onPressed: () {
                          setState(() {
                            selectionMode = false;
                            selectedMssgs = [];
                          });
                        },
                        icon: Icon(Icons.arrow_back)),
                    title: Text("${selectedMssgs.length}"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            // filter has file
                            var xfiles = selectedMssgs
                                .where((e) => e.file != null)
                                .map((e) => XFile(
                                    widget.data.chatDir!.path + "/" + e.file!))
                                .toList();
                            Share.shareXFiles(xfiles);
                          },
                          icon: Icon(Icons.share)),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: selectedMssgs.map((e) {
                              var text = "${e.name}: ";
                              if (e.file != null) {
                                text += "<file: ${e.file}>\n";
                              }
                              if (e.mssg.isNotEmpty) {
                                text += "${e.mssg}\n";
                              }

                              return text;
                            }).join("\n")));
                          },
                          icon: Icon(Icons.copy)),
                    ],
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
                          onPressed: () {},
                          icon: Icon(Icons.videocam_outlined)),
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.call_outlined)),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showMenu(
                              context: context,
                              position: MenuPosition,
                              items: options["default"]!);
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
                      return InkWell(
                        onLongPress: !selectionMode
                            ? () {
                                setState(() {
                                  selectionMode = true;
                                });
                                setState(() {
                                  selectedMssgs
                                      .add(widget.data.messages[index]);
                                });
                              }
                            : null,
                        onTap: selectionMode
                            ? () {
                                var x = selectedMssgs
                                    .indexOf(widget.data.messages[index]);
                                if (x == -1) {
                                  setState(() {
                                    selectedMssgs
                                        .add(widget.data.messages[index]);
                                  });
                                } else {
                                  setState(() {
                                    selectedMssgs.removeAt(x);
                                  });
                                }
                              }
                            : null,
                        child: Container(
                          color: ((currentSearchIndex != -1 &&
                                      searchIndexes[currentSearchIndex] ==
                                          index) ||
                                  (selectionMode &&
                                      selectedMssgs
                                          .any((e) => e.index == index)))
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer
                                  .inc(context, 0.15)
                                  .withOpacity(0.5)
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              MessageBubble(
                                mssg: widget.data.messages[index],
                                isme: isMe,
                                inSelectionMode: selectionMode,
                                dir: widget.data.chatDir,
                              ),
                            ],
                          ),
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
