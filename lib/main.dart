import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'finance tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          // ignore: deprecated_member_use
          background: const Color.fromARGB(255, 227, 239, 237),
          onSurface: HexColor("08100c"), //obsidian
          primary: HexColor("0D7377"), //deep teal
          secondary: HexColor("32E0C4"), //aqua mint
          tertiary: HexColor("393E46"), //charcoal grey
          outline: HexColor("767f7d"), //dark grey
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
