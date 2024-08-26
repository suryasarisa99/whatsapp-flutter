import 'package:flutter/material.dart';

class HiddenScreen extends StatelessWidget {
  const HiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hidden Screen"),
        ),
        body: Column());
  }
}
