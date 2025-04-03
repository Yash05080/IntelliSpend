import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "550454460343-ibjm9b2n99576lcsjt0ohe0el4742evp.apps.googleusercontent.com", // Replace with your OAuth client ID
    scopes: ['email','profile'],
  );

  Future<void> signInWithGoogle() async {
  try {
    print("Attempting Google Sign-In...");
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print("User cancelled sign-in");
      return;
    }

    print("Signed in as: ${googleUser.email}");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      print("Failed to retrieve ID token");
      return;
    }

    print("Sending ID Token to backend...");
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8080/api/auth/google"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode == 200) {
      print("User authenticated successfully: ${response.body}");
    } else {
      print("Authentication failed: ${response.body}");
    }
  } catch (e, stacktrace) {
    print("Error signing in: $e");
    print(stacktrace);
  }
}

}
