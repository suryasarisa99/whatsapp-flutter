import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_chat/models/Messages.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key, required this.data});
  final Messages data;

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  late int direction = widget.data.direction;
  late List<TextEditingController> textEditingControllers = [
    TextEditingController(text: widget.data.names[0]),
    TextEditingController(text: widget.data.names[1]),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Save'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              NameEditBox(
                names: widget.data.names,
                direction: direction,
                controller: textEditingControllers[direction == 0 ? 1 : 0],
              ),
              SizedBox(
                height: 20,
              ),
              NameEditBox(
                names: widget.data.names,
                direction: direction,
                isMe: true,
                controller: textEditingControllers[direction == 0 ? 0 : 1],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        print(direction);
                        setState(() {
                          final newDirection = direction == 0 ? 1 : 0;
                          print(newDirection);
                          direction = newDirection;
                        });
                      },
                      icon: const Icon(Icons.swap_horiz))
                ],
              ),
              Text(direction.toString()),
              FilledButton(
                  onPressed: () {
                    final names = [
                      textEditingControllers[0].text,
                      textEditingControllers[1].text
                    ];
                  },
                  child: Text("save"))
            ],
          ),
        ));
  }
}

class NameEditBox extends StatelessWidget {
  const NameEditBox({
    super.key,
    required this.names,
    required this.direction,
    this.isMe = false,
    required this.controller,
  });

  final List<String> names;
  final int direction;
  final bool isMe;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isMe ? "To" : "From", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          CupertinoTextField(
            placeholder: isMe ? "To" : "From",
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            controller: controller,
            // controller: TextEditingController(
            //     text: names[isMe ? direction : (direction == 0 ? 1 : 0)]),
          ),
        ]),
      ),
    );
  }
}
