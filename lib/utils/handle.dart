import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:whatsapp_chat/models/Messages.dart';

void handleFilePickAndPareMssgs(
    String chatsPath, void Function(Messages messages) onDone) async {
  var result = await FilePicker.platform.pickFiles(
    allowMultiple: false, // optional
    type: FileType.custom,
    allowedExtensions: ['txt', 'zip'], // optional
  );
  if (result != null) {
    var filePath = result.files.single.path!;
    if (filePath.endsWith(".zip")) {
      // get archive
      var bytes = File(filePath).readAsBytesSync();
      var archive = ZipDecoder().decodeBytes(bytes);
      // create output path
      var outputId = DateTime.now().millisecondsSinceEpoch.toString();
      var outputPath = p.join(chatsPath, outputId);
      // extract archive to output path
      await extractArchiveToDisk(archive, outputPath);
      // get chat file
      var outputDir = Directory(outputPath);
      var chatFile = outputDir.listSync().firstWhere((file) =>
          file is File &&
          (p.basename(file.path) == "_chat.txt" ||
              (file.path.endsWith('.txt') &&
                  p.basename(file.path).startsWith("WhatsApp Chat"))));

      var text = await File(chatFile.path).readAsString();
      final mssgs = parseMessages(text, chatFile.path);
      debugPrint("messages length: ${mssgs.length}");
      final names = getNames(mssgs.sublist(0, min(30, mssgs.length)));
      if (names.length == 1) {
        names.add("");
      }

      int direction = guessDirection(names, chatFile.path, filePath);

      // delete old file and create new file with json data
      chatFile.deleteSync();
      var jsonEncodableMessages = mssgs.map((msg) => msg.toJson()).toList();
      var jsonData = jsonEncode(jsonEncodableMessages);
      var newChatFile = File(p.join(outputPath, "chat.json"));
      await newChatFile.writeAsString(jsonData);

      final messages = Messages(
        messages: mssgs,
        chatId: outputId,
        chatDir: outputDir,
        isFolder: true,
        names: names,
        direction: direction,
      );

      onDone(messages);
    } else {
      debugPrint("Text file");
      var text = await File(filePath).readAsString();

      final messgs = parseMessages(text, result.files.single.name);
      final names = getNames(messgs.sublist(0, 20));
      final chatId = DateTime.now().millisecondsSinceEpoch.toString();
      final chatFile = File(p.join(chatsPath, "$chatId.json"));
      await chatFile.writeAsString(
          jsonEncode(messgs.map((msg) => msg.toJson()).toList()));

      final messages = Messages(
        messages: messgs,
        names: names,
        chatDir: null,
        isFolder: false,
        chatId: chatId,
      );
      onDone(messages);
    }
  }
}

List<Message> parseMessages(String text, String fileName) {
  String splitMssg = "";
  List<String> messages;

  if (text.startsWith("[")) {
    // new format
    messages = text.split(
        RegExp(r'\n(?=\[\d\d\/\d\d\/\d\d, \d\d?:\d\d:\d\d\s(?:PM|AM)] )'));
    splitMssg = "] ";
    // remove first two lines
    messages.removeAt(0);
    messages.removeAt(0);
  } else {
    // old format
    messages = text.split(RegExp(
        r'\n(?=\d\d?\/\d\d?\/\d\d\d?\d?, \d\d?:\d\d\s?(?:pm|am|PM|AM)? - )'));
    splitMssg = " - ";
    messages.removeAt(0);
  }
  const whatsappInfoStr =
      "Messages and calls are end-to-end encrypted. No one outside of this chat, not even WhatsApp, can read or listen to them. Tap to learn more.";

  return messages
      .map((message) {
        List<String> parts = message.split(splitMssg);
        String timestamp = parts[0];
        String content = parts.sublist(1).join(splitMssg);
        List<String> timestampParts = timestamp.split(", ");
        String date = timestampParts[0].trim();
        String time = timestampParts[1].trim();
        List<String> contentParts = content.split(":");
        String name = contentParts[0].trim();
        String mssg = contentParts.sublist(1).join(":").trim();
        String? file;

        if (mssg.contains("(file attached)")) {
          List<String> fileParts = mssg.split("(file attached)");
          file = fileParts[0].trim();
          mssg = fileParts[1].trim();
        }

        final m = Message(
          mssg: mssg,
          name: name,
          time: time,
          date: date,
          file: file,
        );

        return m;
      })
      .where((e) =>
          e.name != whatsappInfoStr &&
          (e.mssg != "" || (e.file != null && e.file != "")))
      .toList();
}

List<String> getNames(List<Message> messages) {
  return messages.map((e) => e.name).toSet().toList();
}

int guessDirection(
    List<String> names, String chatFilePath, String archiveName) {
  final chatFileName = p.basename(chatFilePath);
  if (chatFileName.startsWith("_chat.txt")) {
    return 0;
  } else {
    // android
    final name = archiveName
        .replaceFirst("WhatsApp Chat with ", "")
        .replaceFirst(".txt", "");
    final i = names.indexWhere((element) => element == name);
    return i == -1 ? 0 : (i == 0 ? 1 : 0);
  }
}
