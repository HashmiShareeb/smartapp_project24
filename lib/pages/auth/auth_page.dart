// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartapp_project24/pages/auth/login_page.dart';
import 'package:smartapp_project24/pages/nav_page.dart';

//?pagina om te controller ofdat de gebruiker is ingelogd of niet dan verwijzen naar home
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NavPage();
          } else {
            return LoginPage();
          }
          //? als de gebruiker is ingelogd dan verwijzen naar home
          //? als de gebruiker niet is ingelogd dan verwijzen naar login
        },
      ),
    );
  }
}
