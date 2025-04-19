import 'package:supabase_flutter/supabase_flutter.dart';

class Authservice {
  final SupabaseClient _supabase = Supabase.instance.client;

  //sign in with email and pass
  Future<AuthResponse> signinwithEmailandPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(password: password, email: email);
  }

  //sign up with email and pass
  Future<AuthResponse> signupwithEmailandPassword(
      String email, String password) async {
    return await _supabase.auth.signUp(password: password, email: email);
  }

  // sign out
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }

  //get user email
  String? getUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
