import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';
import 'package:finance_manager_app/pages/Login%20page/loginpage.dart';
import 'package:finance_manager_app/pages/Login%20page/otpscreen.dart';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

void main() {
  runApp(MyApp());
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
          background: HexColor("191d2d"), // dark navy blue
          onSurface: HexColor("FFFFFF"), // white (text)
          primary: HexColor("F2C341"), // golden yellow
          secondary: HexColor("f1a410"), // orange
          tertiary: HexColor("f3696e"), // coral pink
          outline: HexColor("f1a410"), // orange (subtext)
        ),
        useMaterial3: true,
      ),
      home: AuthScreen(),
    );
  }
}
