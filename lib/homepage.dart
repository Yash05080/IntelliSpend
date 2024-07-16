import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keep_the_count/Online/Onlinehome.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OnlineHome()));
            },
            child: Container(
              height: 200,
              color: Colors.red,
              child: Center(
                  child: Text(
                "Online",
                style: TextStyle(fontSize: 34),
              )),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 200,
            color: Colors.red,
            child: Center(
                child: Text(
              "Cash",
              style: TextStyle(fontSize: 34),
            )),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 200,
            color: Colors.red,
            child: Center(
                child: Text(
              "Collect",
              style: TextStyle(fontSize: 34),
            )),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
