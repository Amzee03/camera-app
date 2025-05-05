import 'package:flutter/material.dart';
import 'pages/splash_screen.dart'; // ubah ini
// import 'pages/chat_page.dart'; // tidak perlu langsung

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // ubah ke splash screen
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2E7D32),
        scaffoldBackgroundColor: Color(0xFFF1F8E9),
      ),
    );
  }
}
