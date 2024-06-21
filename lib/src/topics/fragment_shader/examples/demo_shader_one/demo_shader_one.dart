import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

class SimpleShaderScreen extends StatelessWidget {
  const SimpleShaderScreen({super.key});

  Future<FragmentShader> _getShader() async {
    try {
      final fragmentProgram =
          await FragmentProgram.fromAsset('shaders/simple.frag');
      return fragmentProgram.fragmentShader();
    } catch (e, s) {
      log("#GetShaderError", error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FragmentShader>(
      future: _getShader(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            painter: SimpleShaderPainter(
                shaderColor: Colors.purple, shader: snapshot.data!),
          );
        } else {
          return const SizedBox(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class SimpleShaderPainter extends CustomPainter {
  final Color shaderColor;
  final FragmentShader shader;
  const SimpleShaderPainter({
    super.repaint,
    required this.shader,
    required this.shaderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, shaderColor.red.toDouble() / 255);
    shader.setFloat(3, shaderColor.green.toDouble() / 255);
    // shader.setFloat(4, shaderColor.blue.toDouble() / 255);
    // shader.setFloat(5, shaderColor.alpha.toDouble() / 255);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
