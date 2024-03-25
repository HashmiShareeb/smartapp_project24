import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //hide back arrow
        automaticallyImplyLeading: false,
        title: const Text('profile'),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Firebase details
          // Add your Firebase details here
          // User's name
          Text('Name: ${user?.displayName ?? 'Guest'}'),
          // User's email
          Text('Email: ${user?.email ?? 'Not available'}'),
          // User's phone number

          // Logout button
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Logout'),
          ),
        ],
      )),
    );
  }
}
