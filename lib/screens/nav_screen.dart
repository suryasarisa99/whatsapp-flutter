import 'package:flutter/material.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/screens/home_screen.dart';
import 'package:whatsapp_chat/screens/root_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 6,
          shadowColor: Colors.black,
          // surfaceTintColor: Colors.red,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.message),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.upgrade),
              label: 'Updates',
            ),
            NavigationDestination(
              icon: Icon(Icons.group),
              label: 'groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.call_outlined),
              label: 'Settings',
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            HomeScreen(),
            RootScreen(),
          ],
        ));
  }
}
