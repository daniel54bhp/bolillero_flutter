import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/help_screen.dart';
import 'screens/credits_screen.dart';

void main() {
  runApp(const BolilleroApp());
}

class BolilleroApp extends StatelessWidget {
  const BolilleroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolillero', // Nombre interno de la app
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/help': (context) => const HelpScreen(),
        '/credits': (context) => const CreditsScreen(),
      },
    );
  }
}
