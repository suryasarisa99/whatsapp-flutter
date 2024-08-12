import 'dart:io';

import 'package:archive/archive_io.dart';

class Message {
  final String mssg;
  final String name;
  final String time;
  final String date;
  final String? file;
  final int mssgGroupType;
  // 0 - normal message
  // 1 - first message in a group
  // 2 - middle message in a group
  // 3 - last message in a group

  Message({
    required this.mssg,
    required this.name,
    required this.time,
    required this.date,
    required this.file,
    this.mssgGroupType = 0,
  });

  Message copyWith({
    String? mssg,
    String? name,
    String? time,
    String? date,
    String? file,
    int? mssgGroupType,
  }) {
    return Message(
      mssg: mssg ?? this.mssg,
      name: name ?? this.name,
      time: time ?? this.time,
      date: date ?? this.date,
      file: file ?? this.file,
      mssgGroupType: mssgGroupType ?? this.mssgGroupType,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      mssg: json['mssg'],
      name: json['name'],
      time: json['time'],
      date: json['date'],
      file: json['file'],
      mssgGroupType: json['mssgGroupType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mssg': mssg,
      'name': name,
      'time': time,
      'date': date,
      'file': file,
      'mssgGroupType': mssgGroupType,
    };
  }
}

class Messages {
  final List<Message> messages;
  final Directory? chatDir;
  final String chatId;
  final bool isFolder;
  final List<String> names;
  int direction;

  Messages({
    required this.messages,
    required this.chatDir,
    this.isFolder = false,
    required this.names,
    this.direction = 0,
    required this.chatId,
  });

  Messages copyWith({
    List<Message>? messages,
    Archive? archive,
    Directory? chatDir,
    String? innerFile,
    bool? isZipFile,
    List<String>? names,
    int? direction,
    String? chatId,
  }) {
    return Messages(
      messages: messages ?? this.messages,
      chatDir: chatDir ?? this.chatDir,
      isFolder: isZipFile ?? this.isFolder,
      names: names ?? this.names,
      direction: direction ?? this.direction,
      chatId: chatId ?? this.chatId,
    );
  }

  static List<Message> messagesFromJson(List json) {
    final List<Message> messages = [];
    for (final mssg in json) {
      messages.add(Message.fromJson(mssg));
    }
    return messages;
  }

  SavedMessageItems toSavedMessageItem() {
    final lastMssg = messages.last.mssg;
    final lastMssgTime = messages.last.time;
    return SavedMessageItems(
      chatId: chatId,
      isFolder: isFolder,
      lastMssg: lastMssg,
      lastMssgTime: lastMssgTime,
      names: names,
      direction: direction,
    );
  }
}

class SavedMessageItems {
  final String chatId;
  final bool isFolder;
  final String? lastMssg;
  final String? lastMssgTime;
  final List<String> names;
  final int direction;

  SavedMessageItems({
    required this.chatId,
    required this.isFolder,
    required this.lastMssg,
    required this.lastMssgTime,
    required this.names,
    required this.direction,
  });

  factory SavedMessageItems.fromJson(Map<String, dynamic> json) {
    return SavedMessageItems(
      chatId: json['filepath'],
      isFolder: json['isZipFile'],
      lastMssg: json['lastMssg'],
      lastMssgTime: json['lastMssgTime'],
      // names: json['names'] as List<String>,
      names: List<String>.from(json['names']),
      direction: json['direction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filepath': chatId,
      'isZipFile': isFolder,
      'lastMssg': lastMssg,
      'lastMssgTime': lastMssgTime,
      'names': names,
      'direction': direction,
    };
  }

  // Future<void> save() async{

  // }
}
