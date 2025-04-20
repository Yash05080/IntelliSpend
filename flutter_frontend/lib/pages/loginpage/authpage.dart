
import 'dart:ui';

import 'package:finance_manager_app/pages/loginpage/registerpage.dart';
import 'package:finance_manager_app/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final authservice = Authservice();

  void login() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    try {
      await authservice.signinwithEmailandPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error $e")));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
            "Welcome again",
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
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: HexColor("C00000"),
                        ),
                        onPressed: _toggleVisibility,
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
                      login();
                      // Handle sign in button press
                    },
                    child: const Text(
                      'Sign In',
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
            height: 10,
          ),

          //forgot password

          InkWell(
            onTap: () {
              //forget pass function
            },
            child: const Text(
              "forgot password?",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          const SizedBox(
            height: 10,
          ),

          //create account

          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()));
            },
            child: RichText(
              text: const TextSpan(children: <TextSpan>[
                TextSpan(text: "Don't have an account? "),
                TextSpan(
                    text: "Sign Up Now",
                    style: TextStyle(color: Colors.red))
              ]),
            ),
          ),
        ],
      ))),
    ]));
  }
}
