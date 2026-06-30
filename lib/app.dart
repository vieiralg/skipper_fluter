import 'package:flutter/material.dart';
import 'game/screens/title_screen.dart';

class SkipperApp extends StatelessWidget {
  const SkipperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skipper',
      debugShowCheckedModeBanner: false,
      home: const TitleScreen(),
    );
  }
}
