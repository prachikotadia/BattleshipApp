import 'package:flutter/material.dart';
import 'package:battleships/views/login_screen.dart';
import 'package:battleships/views/main_app_screen.dart';
import 'package:battleships/utils/utilities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battleships',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: StorageUtil.hasValidToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return snapshot.data == true
              ? FutureBuilder(
                  future: StorageUtil.getUsername(),
                  builder: (context, usernameSnapshot) =>
                      usernameSnapshot.connectionState == ConnectionState.done
                          ? MainAppScreen(username: usernameSnapshot.data ?? "")
                          : const CircularProgressIndicator(),
                )
              : LoginScreen();
        },
      ),
    );
  }
}