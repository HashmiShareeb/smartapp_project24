import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        //hide back arrow
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              print("logged out ${user?.email}");
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user?.displayName ?? user?.email}'),
      ),
    );
  }
}


// child: 