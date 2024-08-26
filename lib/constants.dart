import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const extensions = {
  '.bin': 'binary.png',
  '.binary': 'binary.png',
  '.css': 'css.png',
  '.doc': 'doc.png',
  '.docx': 'doc.png',
  '.document': 'doc.png',
  '.html': 'html.png',
  '.java': 'java.png',
  '.js': 'js.png',
  '.json': 'json.png',
  '.pdf': 'pdf.png',
  '.ppt': 'ppt.png',
  '.pptx': 'ppt.png',
  '.txt': 'txt-l1.png',
  '.xls': 'xls.png',
  '.xlsx': 'xls.png',
  '.py': 'python.png',
  '.rar': 'rar.png',
  '.torrent': 'torrent.png',
  'yaml': 'yaml.png',
  '.zip': 'zip.png',
  '.': 'unknown.png',
  '.jpg': 'jpg.png',
  '.jpeg': 'jpg.png',
  '.png': 'jpg.png',
  // '.key': 'key.png',
  // 'md.png': 'md.png',
  // '.xml': 'xml.png',
  // csv , HEIC, svg
};

class MessageItem {
  final String label;
  final IconData icon;

  const MessageItem(this.label, this.icon);
}

const whatsappPath = "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp";

const messgeTypeMap = {
  0: MessageItem("Texts", FontAwesomeIcons.solidComment),
  1: MessageItem("Images", FontAwesomeIcons.image),
  2: MessageItem("Audios", FontAwesomeIcons.music),
  3: MessageItem("Videos", FontAwesomeIcons.video),
  4: MessageItem("Contacts", FontAwesomeIcons.addressBook),
  5: MessageItem("Locations", FontAwesomeIcons.locationDot),
  7: MessageItem("WA Info Mssgs", FontAwesomeIcons.circleInfo),
  9: MessageItem("Files", FontAwesomeIcons.solidFile),
  10: MessageItem("Old Calls", FontAwesomeIcons.phone),
  11: MessageItem("Wait for Mssg", FontAwesomeIcons.hourglassHalf),
  13: MessageItem("Gifs", Icons.gif_box),
  // 13: MessageItem("Gifs", FontAwesomeIcons.gif),
  14: MessageItem("Multiple Contacts", FontAwesomeIcons.addressBook),
  15: MessageItem("Deleted Mssgs", FontAwesomeIcons.trash),
  20: MessageItem("Stickers", FontAwesomeIcons.noteSticky),
  42: MessageItem("One Time View", FontAwesomeIcons.eyeSlash),
  43: MessageItem("Unwatched One Time View", FontAwesomeIcons.eye),
  64: MessageItem("Deleted by Admin", FontAwesomeIcons.userSlash),
  66: MessageItem("Polls", FontAwesomeIcons.squarePollHorizontal),
  90: MessageItem("Calls", FontAwesomeIcons.phone),
  92: MessageItem("Events", FontAwesomeIcons.calendar),
};
final x = FontAwesomeIcons.squarePollHorizontal;

enum SearchType { Normal, Fuzzy, Date, Advanced }

const MenuPosition = RelativeRect.fromLTRB(
  95,
  50,
  5,
  100,
);

enum MyColors {
  MyChatBubble,
  OtherChatBubble,
  MyInnnerChatBubble,
  OtherInnerChatBubble,
}

Color mycolors(BuildContext context, MyColors myColors) {
  final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
  double LeftMssgInnrDarkness =
      Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.05;
  switch (myColors) {
    case MyColors.MyChatBubble:
      return Theme.of(context).colorScheme.primaryContainer.inc(context, 0.05);
    case MyColors.OtherChatBubble:
      return Theme.of(context)
          .colorScheme
          .secondaryContainer
          .dec(context, 0.08);
    case MyColors.MyInnnerChatBubble:
      return Theme.of(context)
          .colorScheme
          .primaryContainer
          .revDec(context, 0.01);
    case MyColors.OtherInnerChatBubble:
      return Theme.of(context)
          .colorScheme
          .secondaryContainer
          .dec(context, LeftMssgInnrDarkness);
  }
  ;
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
