import 'package:flutter/material.dart';

import 'topics/render_object/render_object_practice.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: RenderObjectPractice(),
      debugShowCheckedModeBanner: false,
    );
  }
}
