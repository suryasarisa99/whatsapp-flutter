import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:whatsapp_chat/components/player_screen.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/screens/db_chat_screen.dart';
import 'package:whatsapp_chat/screens/nav_screen.dart';
import 'package:whatsapp_chat/screens/test_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

SharedPreferences? prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  // sqfliteFfiInit();
  // await DatabaseHelper.instance.database;
  runApp(ProviderScope(child: const MainApp()));
}

var lightColor = Color.fromARGB(255, 182, 52, 180);
var darkColor = lightColor;

var lightColorColorSchema = ColorScheme.fromSeed(
  seedColor: lightColor,
  brightness: Brightness.light,
);

var darkColorColorSchema = ColorScheme.fromSeed(
  seedColor: darkColor,
  brightness: Brightness.dark,
);

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late StreamSubscription _intentSub;
  @override
  void initState() {
    super.initState();
    mPrint("initState");

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      mPrint("file share : Running App: outside if cond");
      print("data: $value");
      if (value.isNotEmpty) {
        mPrint("file share : Running App: inside if cond");
        final filePath = value.first.path;
        final fileName = value.first.path.split("/").last;
        handleChat(filePath, fileName);
        // routes.push("/test");
      } else {
        print("NO data: outside: ${value}");
      }
    }, onError: (err) {});

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      mPrint("file share : Cosed App: outside if cond");
      print("data: $value");

      if (value.isNotEmpty) {
        // routes.go("/test");
        mPrint("file share : Cosed App: inside if cond");
        final filePath = value.first.path;
        final fileName = value.first.path.split("/").last;
        handleChat(filePath, fileName);
      } else {
        print("NO data: ${value}");
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  void mPrint(String mssg) {
    debugPrint("<====================> $mssg <====================>");
  }

  void handleChat(String filePath, String fileName) async {
    final d = await getExternalStorageDirectory();
    // const d =
    // "/storage/emulated/0/Android/data/com.example.whatsapp_chat/files/chats";
    final chatsPath = p.join(d!.path, "chats");
    handleData(chatsPath, filePath, fileName, (Messages messages) {
      final savedMssgItem = messages.toSavedMessageItem();
      ref.read(savedChatsProvider.notifier).addChat(savedMssgItem);
      mPrint("handledChat Successfull");
      routes.push("/chat", extra: messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      if (lightDynamic == null) {
        debugPrint("lightDynamic is null");
      }
      if (darkDynamic == null) {
        debugPrint("darkDynamic is null");
      }

      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: lightDynamic,
        ),
        darkTheme: ThemeData.dark(useMaterial3: true)
            .copyWith(colorScheme: darkDynamic),
        routerConfig: routes,
      );
    });
  }
}
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       theme: ThemeData.light(useMaterial3: true).copyWith(
//         colorScheme: lightColorColorSchema,
//       ),
//       debugShowCheckedModeBanner: false,
//       darkTheme: ThemeData.dark(useMaterial3: true)
//           .copyWith(colorScheme: darkColorColorSchema),
//       routerConfig: routes,
//     );
//   }
// }

final routes = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
        path: "/home",
        pageBuilder: (context, state) =>
            const MaterialPage(child: NavScreen())),
    GoRoute(
        path: "/chat",
        pageBuilder: (context, state) {
          return MaterialPage(child: ChatScreen(data: state.extra as Messages));
        }),
    GoRoute(
        path: "/dbchat",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: DbChatScreen(data: state.extra as DbMssgs));
        }),
    GoRoute(
        path: "/video",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: PlayerScreen(filePath: state.extra as String));
        }),
    GoRoute(
        path: "/test",
        pageBuilder: (context, state) {
          return MaterialPage(child: TestScreen());
        }),
    // GoRoute(
    //     path: "/save",
    //     pageBuilder: (context, state) {
    //       return MaterialPage(child: SaveScreen(data: state.extra as Messages));
    //     }),
  ],
);
