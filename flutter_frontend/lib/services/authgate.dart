import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';
import 'package:finance_manager_app/pages/loginpage/authpage.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Correctly unpacking event and session
        final data = snapshot.data;
        final session = data?.session;

        if (session != null) {
          return const MyHomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
