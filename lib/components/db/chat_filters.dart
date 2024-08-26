import 'package:flutter/material.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class ChatFilters extends StatelessWidget {
  const ChatFilters(
      {super.key,
      required this.filters,
      required this.selectedFilter,
      required this.handleFilter});

  final int selectedFilter;
  final List<Map<String, Object>> filters;
  final void Function(int i) handleFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((e) {
            if (filters.indexOf(e) == selectedFilter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    (e['handler']! as void Function())();
                    handleFilter(filters.indexOf(e));
                  },
                  child: Container(
                    constraints: BoxConstraints(minWidth: 60),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18)),
                    child: Text(
                      e['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  (e['handler']! as void Function())();
                  handleFilter(filters.indexOf(e));
                },
                child: Container(
                  constraints: BoxConstraints(minWidth: 60),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surface.lighten(0.03),
                      borderRadius: BorderRadius.circular(18)),
                  child: Text(
                    e['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
