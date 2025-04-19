import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';
import 'package:finance_manager_app/pages/loginpage/authpage.dart';


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          //if loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return MyHomePage();
          } else
            return LoginPage();
        });
  }
}
