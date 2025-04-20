import 'dart:async';

import 'package:finance_manager_app/services/authgate.dart';

import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finance_manager_app/pages/loginpage/authpage.dart';

Future<void> main() async {
  // Make sure ensureInitialized is *inside* the zone
  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: "https://iocaalxfpskzwcoudzyy.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvY2FhbHhmcHNrendjb3Vkenl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNDI4MzUsImV4cCI6MjA2MDYxODgzNX0.7eiPNbZbmk9BMWyNbQfqSknc82wwzyEYBE5U-QEMHaA",
    );

    runApp(const MyApp());
  }, (error, stackTrace) {
    // now you’ll catch everything properly
    print("Uncaught error: $error");
    print(stackTrace);
  });
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
      home: AuthGate(),
    );
  }
}
