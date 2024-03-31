import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/topics/animation/animation_example_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: false),
      home: const AnimationExampleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
