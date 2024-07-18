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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(16),
              height: 55,
              width: double.maxFinite,
              color: Colors.grey,
              child: Text("total online expense"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container()
        ],
      ),
    );
  }
}
