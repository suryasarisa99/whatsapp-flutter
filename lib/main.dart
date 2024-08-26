import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_chat/components/db/chat_profile.dart';
import 'package:whatsapp_chat/components/player_screen.dart';
import 'package:whatsapp_chat/models/DbModels.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/providers/saved_chats_provider.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/screens/db_chat_screen.dart';
import 'package:whatsapp_chat/screens/hidden_screen.dart';
import 'package:whatsapp_chat/screens/image_preview_screen.dart';
import 'package:whatsapp_chat/screens/message_preview_screen.dart';
import 'package:whatsapp_chat/screens/nav_screen.dart';
import 'package:whatsapp_chat/screens/search_screen.dart';
import 'package:whatsapp_chat/utils/handle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

SharedPreferences? prefs;
late final String externalDir;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  externalDir = (await getExternalStorageDirectory())!.path;
  debugPrint("internalDir: $externalDir");
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

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      print("data: $value");
      if (value.isNotEmpty) {
        final filePath = value.first.path;
        final fileName = value.first.path.split("/").last;
        handleChat(filePath, fileName);
      } else {
        print("NO data: outside: ${value}");
      }
    }, onError: (err) {});

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        final filePath = value.first.path;
        final fileName = value.first.path.split("/").last;
        handleChat(filePath, fileName);
      } else {
        print("NO data: ${value}");
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  void handleChat(String filePath, String fileName) async {
    final d = await getExternalStorageDirectory();
    final chatsPath = p.join(d!.path, "chats");
    handleData(chatsPath, filePath, fileName, (Messages messages) {
      final savedMssgItem = messages.toSavedMessageItem();
      ref.read(savedChatsProvider.notifier).addChat(savedMssgItem);
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
        path: "/dbchat-profile",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: DbChatProfileScreen(chat: state.extra as DbChat));
        }),
    GoRoute(
        path: "/image-preview",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: ImagePreviewScreen(mssg: state.extra as DbMssgImageFile));
        }),
    GoRoute(
        path: "/messages-preview",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: MessagPreviewScreen(mssgs: state.extra as List<DbMssg>));
        }),
    GoRoute(
        path: "/video",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: PlayerScreen(filePath: state.extra as String));
        }),
    GoRoute(
        path: "/hidden",
        pageBuilder: (context, state) {
          return MaterialPage(child: HiddenScreen());
        }),

    GoRoute(
        path: "/search",
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: SearchScreen(data: state.extra as List<DbChat>),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.05);
              const end = Offset(0.0, 0.0);
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        }),

    // GoRoute(
    //     path: "/save",
    //     pageBuilder: (context, state) {
    //       return MaterialPage(child: SaveScreen(data: state.extra as Messages));
    //     }),
  ],
);
