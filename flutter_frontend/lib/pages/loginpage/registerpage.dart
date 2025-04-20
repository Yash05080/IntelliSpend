import 'dart:ui';

import 'package:finance_manager_app/pages/loginpage/authpage.dart';
import 'package:finance_manager_app/services/authgate.dart';
import 'package:finance_manager_app/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final authservice = Authservice();

  void signUp() async {
  final email = _usernameController.text.trim();
  final password = _passwordController.text;
  final confirm = _confirmpasswordController.text;

  if (password != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")));
    return;
  }

  try {
    final res = await authservice.signupwithEmailandPassword(email, password);

    if (res.user != null) {
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e",style: const TextStyle(color: Colors.red),)));
    }
  }
}


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/login.jpg"),
              fit: BoxFit.cover,
              //opacity: 0.4,
            )),
      ),
      SafeArea(
          child: Center(
              child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          //brand name
          const Text(
            "IntelliSpend",
            style: TextStyle(fontSize: 40, color: Colors.red),
          ),
          const SizedBox(
            height: 10,
          ),

          //welcome text
          const Text(
            "Bonjour Patron",
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(
            height: 40,
          ),

          //Username textfield

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: TextField(
                    controller: _usernameController,
                    style: TextStyle(color: HexColor("FFD078")),
                    cursorColor: HexColor("FFD078"),
                    decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.person,
                          color: HexColor("C00000"),
                        ),
                        hintText: "username",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                  ),
                )),
          ),
          const SizedBox(
            height: 30,
          ),

          // password textfield

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: TextField(
                    controller: _passwordController,
                    style: TextStyle(color: HexColor("FFD078")),
                    cursorColor: HexColor("FFD078"),
                    cursorErrorColor: Colors.red,
                    decoration: InputDecoration(
                      hintText: "password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.lock,
                        color: HexColor("C00000"),
                      ),
                    ),
                  ),
                )),
          ),

          const SizedBox(
            height: 20,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: TextField(
                    controller: _confirmpasswordController,
                    style: TextStyle(color: HexColor("FFD078")),
                    cursorColor: HexColor("FFD078"),
                    cursorErrorColor: Colors.red,
                    decoration: InputDecoration(
                      hintText: "confirm password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.lock_reset,
                        color: HexColor("C00000"),
                      ),
                    ),
                  ),
                )),
          ),

          const SizedBox(
            height: 20,
          ),

          //login in button

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Frosted glass effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                // Elevated button on top of the frosted glass effect
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      signUp();
                      // Handle sign in button press
                    },
                    child: const Text(
                      'create account',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          //forgot password

          //create account

          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: RichText(
              text: const TextSpan(children: <TextSpan>[
                TextSpan(text: "Already have an account? "),
                TextSpan(
                    text: "Sign In Now", style: TextStyle(color: Colors.red))
              ]),
            ),
          ),
        ],
      ))),
    ]));
  }
}
