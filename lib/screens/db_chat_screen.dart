import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:whatsapp_chat/components/chat_appbar.dart';
import 'package:whatsapp_chat/components/chat_background.dart';
import 'package:whatsapp_chat/components/chat_input.dart';
import 'package:whatsapp_chat/components/chat_search_bar.dart';
import 'package:whatsapp_chat/components/db/message_bubles.dart/message_buble.dart';
import 'package:whatsapp_chat/components/menu_item.dart';
import 'package:whatsapp_chat/components/message_bubble.dart';
import 'package:whatsapp_chat/components/message_bubble.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class DbChatScreen extends StatefulWidget {
  const DbChatScreen({super.key, required this.data});
  final DbMssgs data;

  @override
  State<DbChatScreen> createState() => _DbChatScreenState();
}

class _DbChatScreenState extends State<DbChatScreen> {
  bool isOnTop = false;
  final _scrollController = ItemScrollController();
  // final _scrollOffsetController = ScrollOffsetController();
  final _searchQueryController = TextEditingController();
  bool searchMode = false;
  FocusNode searchNode = FocusNode();
  SearchType searchType = SearchType.Date;
  bool selectionMode = false;
  List<DbMssg> selectedMssgs = [];
  Map<int, int> hashCodeToIndexMap = {};

  List<int> searchIndexes = [];
  int currentSearchIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeHashCodeToIndexMap();
  }

  void _initializeHashCodeToIndexMap() {
    for (int i = 0; i < widget.data.mssgs.length; i++) {
      hashCodeToIndexMap[widget.data.mssgs[i].hashCode] = i;
    }
  }

  void handleSearch() {
    final List<int> _searchResults;
    if (searchType == SearchType.Fuzzy) {
      var mssgsfuzzy = Fuzzy(widget.data.mssgs,
          options: FuzzyOptions(
            keys: [
              WeightedKey(
                  name: "mssg", getter: (DbMssg x) => x.text ?? "", weight: 1)
            ],
          ));

      _searchResults = mssgsfuzzy
          .search(_searchQueryController.text)
          .map((e) => e.item.hashCode)
          .toList();
    } else {
      _searchResults = widget.data.mssgs
          .where((e) =>
              e.text
                  ?.toLowerCase()
                  .contains(_searchQueryController.text.toLowerCase()) ??
              false)
          .map((e) => e.hashCode)
          .toList();
    }

    debugPrint("Search Results: $_searchResults");

    setState(() {
      if (_searchResults.isNotEmpty) {
        debugPrint("All: ${hashCodeToIndexMap}");
        searchIndexes = _searchResults
            .map((hashCode) => hashCodeToIndexMap[hashCode] ?? -1)
            .toList();
        debugPrint("Search Indexes: $searchIndexes");
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
      searchIndexes = [];
      currentSearchIndex = -1;
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
    Map<String, List<PopupMenuItem>> options = {};
    List<PopupMenuItem> defaultOptions = [
      CustomMenuItem(
          onTap: () async {
            setState(() {
              isOnTop = !isOnTop;
              scrollToIndex(isOnTop ? widget.data.mssgs.length - 1 : 0);
            });
          },
          icon: Icons.swap_vert,
          title: isOnTop ? "Go Bottom" : "Go Top"),
      CustomMenuItem(
          onTap: () {
            showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(95, 50, 5, 100),
                items: options["search"]!);
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
                  handleSearch: handleSearch,
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
              : ChatAppbar(
                  goChatProfile: () => GoRouter.of(context)
                      .push("/dbchat-profile", extra: widget.data.chat),
                  pic: widget.data.chat.rawJid,
                  title: widget.data.chat.groupName ?? widget.data.chat.no,
                  options: options,
                ),
          body: Stack(
            children: [
              const ChatBackground(),
              Column(
                children: [
                  Expanded(
                    child: ScrollablePositionedList.builder(
                      itemCount: widget.data.mssgs.length,
                      itemScrollController: _scrollController,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final mssg = widget.data.mssgs[index];
                        return Container(
                          color: ((currentSearchIndex != -1 &&
                                  searchIndexes[currentSearchIndex] == index))
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer
                                  .inc(context, 0.15)
                                  .withOpacity(0.5)
                              : Colors.transparent,
                          child: Row(
                            mainAxisAlignment: mssg.me == 1
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              DbMssgBubble(
                                mssg: mssg,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  ChatInputField(),
                ],
              )
            ],
          )),
    );
  }
}
