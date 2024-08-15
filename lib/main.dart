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
          background: Color.fromARGB(255, 227, 239, 237),
          onBackground: HexColor("08100c"), //obsidian
          primary: HexColor("b3eda9"), //light green
          secondary: HexColor("009a6e"), //dark green
          tertiary: HexColor("e8e300"), //yellow
          outline: HexColor("767f7d"), //dark grey
          
        ),
        
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

