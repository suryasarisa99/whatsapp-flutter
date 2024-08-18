import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_chat/main.dart';
import 'package:whatsapp_chat/models/Messages.dart';

class SavedChatsProvider extends StateNotifier<List<SavedMessageItems>> {
  SavedChatsProvider() : super([]) {
    debugPrint("Loading Chats");
    final rawtext = prefs!.getString("chats");
    final rawData = jsonDecode(rawtext ?? "[]") as List;
    state = rawData
        .map((e) => SavedMessageItems.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    print("Loaded Chats: $state");
    print("len: ${state.length}");
  }

  void init() {}

  void setChats(List<SavedMessageItems> chats) {
    state = chats;
  }

  void addChat(SavedMessageItems chat) {
    state = [...state, chat];
    prefs!
        .setString("chats", jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  void removeChat(int index) {
    // state = state..removeAt(index);
    state = [...state..removeAt(index)];
    prefs!
        .setString("chats", jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}

final savedChatsProvider =
    StateNotifierProvider<SavedChatsProvider, List<SavedMessageItems>>((ref) {
  return SavedChatsProvider();
});
