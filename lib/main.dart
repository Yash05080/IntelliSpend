import 'package:flutter/material.dart';
import 'package:keep_the_count/Database/expense_database.dart';
import 'package:keep_the_count/frosted.dart';
import 'package:keep_the_count/homepage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize db
  await ExpenseDatabase.initialize();

  runApp(ChangeNotifierProvider(
    create: (context) => ExpenseDatabase(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 119, 255, 0)),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
