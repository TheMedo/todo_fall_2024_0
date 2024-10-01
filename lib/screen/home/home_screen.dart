import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          const Text('Hello'),
          Text(FirebaseAuth.instance.currentUser?.email ?? 'N/A'),
          const Spacer(),
          OutlinedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Text('Sign out'),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
