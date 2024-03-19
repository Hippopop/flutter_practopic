import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/time_ticker.dart';

class ToyGradientShaderScreen extends StatelessWidget {
  const ToyGradientShaderScreen({super.key});

  Future<FragmentShader> _getShader() async {
    try {
      final fragmentProgram =
          await FragmentProgram.fromAsset('shaders/toy_mozice.frag');
      final frag = fragmentProgram.fragmentShader();

      return frag;
    } catch (e, s) {
      log("#GetShaderError", error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FragmentShader>(
        future: _getShader(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox.square(
                  dimension: 200,
                  child: TickingBuilder(
                    builder: (context, time) => CustomPaint(
                      painter: ToyGradientShaderPainter(
                        time: time,
                        shader: snapshot.data!,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class ToyGradientShaderPainter extends CustomPainter {
  final double time;
  final FragmentShader shader;

  const ToyGradientShaderPainter({
    super.repaint,
    required this.time,
    required this.shader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
      // ..blendMode = BlendMode.src,
    );
  }

  @override
  bool shouldRepaint(covariant ToyGradientShaderPainter oldDelegate) {
    return time != oldDelegate.time || shader != oldDelegate.shader;
  }
}
