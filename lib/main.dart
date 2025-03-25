import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';
import 'package:finance_manager_app/pages/login/login.dart';
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
          background: HexColor("191d2d"),
          onSurface: HexColor("FFFFFF"), //text
          primary: HexColor("F2C341"), //deep teal
          secondary: HexColor("f1a410"), //aqua mint
          tertiary: HexColor("f3696e"), //charcoal grey
          outline: HexColor("f1a410"), //subtext
        ),
        useMaterial3: true,
      ),
      home: AuthScreen(),
    );
  }
}
