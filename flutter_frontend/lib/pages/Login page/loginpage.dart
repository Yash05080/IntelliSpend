import 'package:finance_manager_app/pages/Login%20page/authservice.dart';
import 'package:finance_manager_app/pages/Login%20page/otpscreen.dart';
import 'package:finance_manager_app/pages/Login%20page/register.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("191d2d"), // Dark navy blue
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HexColor("FFFFFF"), // white text
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                style: GoogleFonts.poppins(
                    fontSize: 16, color: HexColor("FFFFFF").withOpacity(0.7)),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HexColor("2a2f45"), // lighter navy blue background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border:
                              Border.all(color: HexColor("f1a410")), // outline
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextField(
                            controller: _usernameController,
                            style: TextStyle(
                                color: HexColor("F2C341")), // golden yellow
                            cursorColor: HexColor("F2C341"),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.person,
                                color: HexColor("f3696e"), // coral pink icon
                              ),
                              hintText: "username",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: HexColor("f1a410")),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextField(
                            controller: _passwordController,
                            style: TextStyle(color: HexColor("F2C341")),
                            cursorColor: HexColor("F2C341"),
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: "password",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: HexColor("f3696e"),
                                ),
                                onPressed: _toggleVisibility,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          String generatedOTP =
                              "123456"; // This would come from your API or service

// Navigate to OTP verification page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTPScreen(
                                expectedOTP:
                                    generatedOTP, // Pass the OTP to verify against
                                
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              HexColor("F2C341"), // golden yellow button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 16,
                              color: HexColor("191d2d")), // dark text on yellow
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: HexColor("f1a410"),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  print("button clicked");
                  
                  print("auth done");
                },
                icon: Icon(FontAwesomeIcons.google, color: Colors.white),
                label: Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("f3696e"), // coral pink
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: HexColor("FFFFFF")),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: HexColor("f1a410"),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
