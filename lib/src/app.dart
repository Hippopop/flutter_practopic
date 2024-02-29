import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/demo_shader_one.dart';

import 'topics/render_object/render_object_practice.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: SimpleShaderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
