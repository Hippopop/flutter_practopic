import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/topics/isolates/isolate_example_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: FlutterIsolateDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
