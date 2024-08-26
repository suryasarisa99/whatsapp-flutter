import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.searchNode,
    required this.handleSearch,
    required this.handleSearchCancel,
    required this.handleNext,
    required this.handlePrevious,
    required this.searchQueryController,
  });

  final TextEditingController searchQueryController;
  final FocusNode searchNode;
  final Function handleSearch;
  final void Function() handleSearchCancel;
  final Function handleNext;
  final Function handlePrevious;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: CupertinoTextField(
        placeholder: "Search",
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        focusNode: searchNode,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(25),
        ),
        controller: searchQueryController,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        prefix: Padding(
            padding: EdgeInsets.only(left: 8),
            child: IconButton(
                onPressed: handleSearchCancel, icon: Icon(Icons.arrow_back))),
        onSubmitted: (_) {
          handleSearch();
        },
        suffix: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    handleNext();
                  },
                  icon: FaIcon(FontAwesomeIcons.chevronUp, size: 17)),
              IconButton(
                  onPressed: () {
                    handlePrevious();
                  },
                  icon: FaIcon(FontAwesomeIcons.chevronDown, size: 17)),
            ],
          ),
        ),
      ),
    );
  }
}
