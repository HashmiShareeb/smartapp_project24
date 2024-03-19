import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        title: Text('Home'),
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
      body: Container(
        color: Colors.teal,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  child: RichText(
                      text: TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(
                      color: Colors.teal[900],
                      fontSize: 20,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: user?.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// child:
