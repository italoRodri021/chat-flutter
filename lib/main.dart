import 'package:chat_flutter/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP CHAT',
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.green),
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}
