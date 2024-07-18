import 'package:flutter/material.dart';
import 'package:keep_the_count/Database/expense_database.dart';
import 'package:keep_the_count/frosted.dart';
import 'package:keep_the_count/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize db
  await ExpenseDatabase.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FrostedContainer(),
    );
  }
}
