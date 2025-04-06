import 'package:chat_bot_app/chatbot.page.dart';
import 'package:chat_bot_app/home_page.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        indicatorColor: Colors.white,
      ),
      routes: {
        "/chat" : (context)=>ChatbotPage(),
      },
      home: HomePage(),
    );
  }
}
