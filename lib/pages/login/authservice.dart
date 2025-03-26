import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "550454460343-ibjm9b2n99576lcsjt0ohe0el4742evp.apps.googleusercontent.com",  // Replace with your OAuth client ID
    scopes: ['email'],
  );

  Future<void> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in

      // Step 2: Obtain authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String idToken = googleAuth.idToken!;

      // Step 3: Send the ID token to your backend
      final response = await http.post(
        Uri.parse("http://your-backend.com/api/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        print("User authenticated successfully: ${response.body}");
      } else {
        print("Authentication failed: ${response.body}");
      }
    } catch (e) {
      print("Error signing in: $e");
    }
  }
}
