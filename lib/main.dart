import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:whatsapp_chat/models/Database.dart';
import 'package:whatsapp_chat/models/Messages.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/screens/nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqfliteFfiInit();
  // await DatabaseHelper.instance.database;
  runApp(const MainApp());
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
    // GoRoute(
    //     path: "/save",
    //     pageBuilder: (context, state) {
    //       return MaterialPage(child: SaveScreen(data: state.extra as Messages));
    //     }),
  ],
);
