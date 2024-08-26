import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatsapp_chat/constants.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key});

  @override
  Widget build(BuildContext context) {
    const svgs = [
      "bubbles.svg",
      "circuit-board.svg",
      "line-in-motion.svg",
      "topography.svg",
      "wiggle.svg",
      "random-shapes.svg"
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double patternOpacity = isDark ? 0.16 : 0.8;
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.darken(0.02),
          // color: Color(0xff080c11), #whatsapp dark background
        ),
        // whatsapp pattern
        child: Opacity(
            opacity: patternOpacity,
            child: Image.asset(
              "assets/patterns/doggles.png",
              fit: BoxFit.cover,
            )),

        // child: SvgPicture.asset(
        //   'assets/patterns/line-in-motion.svg',
        //   fit: BoxFit.contain,
        // ),

        // child: GridView.builder(
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 6, // Adjust the number of columns as needed
        //   ),
        //   itemBuilder: (context, index) {
        //     return Opacity(
        //       opacity: patternOpacity,
        //       child: SvgPicture.asset(
        //         'assets/patterns/${svgs[5]}',
        //         fit: BoxFit.cover,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}
