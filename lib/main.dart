import 'package:flutter/material.dart';
import 'pages/welcome.dart';

void main() {
  runApp(const CatchCheckApp());
}

class CatchCheckApp extends StatelessWidget {
  const CatchCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CatchCheck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: WelcomePage(),
    );
  }
}