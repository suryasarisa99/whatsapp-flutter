import 'package:flutter/material.dart';

class ChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppbar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 5);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
            child: Text(title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 19)),
          ),
        ],
      ),
      leadingWidth: 24,
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.videocam_outlined)),
        IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined)),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            //   showMenu(
            //       context: context,
            //       position: const RelativeRect.fromLTRB(
            //         95,
            //         50,
            //         5,
            //         100,
            //       ),
            //       items: [
            //         PopupMenuItem(
            //           child: const Row(
            //             children: [
            //               Icon(Icons.swap_horiz),
            //               SizedBox(width: 16),
            //               Text('Swap'),
            //             ],
            //           ),
            //           onTap: () {},
            //         ),
            //         PopupMenuItem(
            //           child: const Row(
            //             children: [
            //               Icon(Icons.arrow_downward),
            //               SizedBox(width: 16),
            //               Text('Go Bottom'),
            //             ],
            //           ),
            //           onTap: () {},
            //         ),
            //       ]);
          },
        ),
      ],
    );
  }
}
