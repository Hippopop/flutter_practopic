import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/services/router.dart';
import 'package:flutter_practopic/src/topics/animation/animation_example_screen.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/demo_shader_one.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/ripple_example.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/toy_gradient.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/transparent_demo.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: false),
      debugShowCheckedModeBanner: false,
    );
  }
}
