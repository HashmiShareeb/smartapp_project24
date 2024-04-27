// ignore_for_file: prefer_const_constructors

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
        automaticallyImplyLeading: false, // hide back arrow
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User's profile icon
            Icon(
              Icons.account_circle,
              size: 50,
            ),
            SizedBox(width: 16), // Add spacing between icon and text
            // Column to display name and email below each other
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User's name
                Text(
                  user?.displayName ?? 'Guest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // User's email
                Text(
                  user?.email ?? 'Not available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Logout button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Profile'),
              trailing: CircleAvatar(
                backgroundColor: Colors.orange[300],
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // Navigate to Profile page
              },
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
            ListTile(
              title: const Text('Notifications'),
              trailing: CircleAvatar(
                backgroundColor: Colors.orange[300],
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                //display notifications
              },
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: CircleAvatar(
                backgroundColor: Colors.orange[300],
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
