import 'package:flutter/material.dart';
import 'package:whatsapp_chat/models/DbModels.dart';

class PollMssgBubble extends StatelessWidget {
  const PollMssgBubble({super.key, required this.dbMssgPoll});
  final DbMssgPoll dbMssgPoll;

  @override
  Widget build(BuildContext context) {
    int totalVotes =
        dbMssgPoll.pollOptions.fold(0, (sum, option) => sum + option.count);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                dbMssgPoll.text ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 12),
            ...[
              for (var i = 0; i < dbMssgPoll.pollOptions!.length; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (x) {}),
                        Text(dbMssgPoll.pollOptions[i].option),
                      ],
                    ),
                    Text(dbMssgPoll.pollOptions[i].count.toString())
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: totalVotes > 0
                            ? dbMssgPoll.pollOptions![i].count / totalVotes
                            : 0,
                        minHeight: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ]
            ]
          ],
        ),
      ),
    );
  }
}
