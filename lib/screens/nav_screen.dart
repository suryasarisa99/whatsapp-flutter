import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp_chat/screens/chat_screen.dart';
import 'package:whatsapp_chat/screens/home_screen.dart';
import 'package:whatsapp_chat/screens/db_home_screen.dart';

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
          destinations: [
            NavigationDestination(
              // icon: Icon(Icons.message),
              icon: FaIcon(
                selectedIndex == 0
                    ? FontAwesomeIcons.solidMessage
                    : FontAwesomeIcons.message,
                size: 17,
              ),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: FaIcon(
                FontAwesomeIcons.database,
                size: 16,
              ),
              label: 'Database',
            ),
            NavigationDestination(
              icon:
                  Icon(selectedIndex == 2 ? Icons.group : Icons.group_outlined),
              label: 'groups',
            ),
            NavigationDestination(
              icon: Icon(
                selectedIndex == 3 ? Icons.phone : Icons.phone_outlined,
              ),
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
