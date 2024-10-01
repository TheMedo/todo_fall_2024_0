import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart';
import 'package:todo_fall_2024_0/screen/login/login_screen.dart';

class RouterScreen extends StatelessWidget {
  const RouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userStream = FirebaseAuth.instance.authStateChanges();
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return LoginScreen();
        } else {
          return HomeScreen();
        }
      },
    );
  }
}
