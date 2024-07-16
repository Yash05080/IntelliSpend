import 'package:flutter/material.dart';

class OnlineHome extends StatefulWidget {
  const OnlineHome({super.key});

  @override
  State<OnlineHome> createState() => _OnlineHomeState();
}

class _OnlineHomeState extends State<OnlineHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online"),
      ),
    );
  }
}
