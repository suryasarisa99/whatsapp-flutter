import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whatsapp_chat/constants.dart';

class DummySearchBar extends StatelessWidget {
  const DummySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sbColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.lighten(0.05)
        : Theme.of(context).colorScheme.primaryContainer.lighten(0.14);
    return Hero(
      tag: 'home-search-bar-2',
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: sbColor,
          ),
          child: Row(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
                child: Icon(Icons.search),
              ),
              SizedBox(width: 5),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                    fontSize: 16,
                  ),
                  child: Text(
                    "Ask Meta Ai or Search",
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
