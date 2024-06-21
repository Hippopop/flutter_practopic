import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:go_router/go_router.dart';

class RippleDemoPage extends StatefulWidget {
  const RippleDemoPage({super.key});

  @override
  State<RippleDemoPage> createState() => _RippleDemoPageState();
}

class _RippleDemoPageState extends State<RippleDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: buildImage(),
            ),
          );
        },
      ),
    );
  }

  Offset _pointer = Offset.zero;

  void _updatePointer(PointerEvent details) {
    _controller.reset();
    _controller.forward();
    setState(() {
      _pointer = details.localPosition;
    });
  }

  Widget buildImage() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: ShaderBuilder(
            (context, shader, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedSampler(
                  (image, size, canvas) {
                    ShaderHelper.configureShader(
                      shader,
                      size,
                      image,
                      time: _controller.value * 15.0,
                      pointer: _pointer,
                    );
                    ShaderHelper.drawShaderRect(shader, size, canvas);
                  },
                  child: Listener(
                    onPointerMove: _updatePointer,
                    onPointerDown: _updatePointer,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "images/image-2.jpg",
                          fit: BoxFit.cover,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.push("/");
                          },
                          child: const Text("Let's Check"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            assetKey: "shaders/ripple.frag",
          ),
        );
      },
    );
  }
}

class ShaderHelper {
  static void configureShader(
    ui.FragmentShader shader,
    ui.Size size,
    ui.Image image, {
    required double time,
    required Offset pointer,
  }) {
    shader
      ..setFloat(0, size.width) // iResolution
      ..setFloat(1, size.height) // iResolution
      ..setFloat(2, pointer.dx) // iMouse
      ..setFloat(3, pointer.dy) // iMouse
      ..setFloat(4, time) // iTime
      ..setImageSampler(0, image); // image
  }

  static void drawShaderRect(
    ui.FragmentShader shader,
    ui.Size size,
    ui.Canvas canvas,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      Paint()..shader = shader,
    );
  }
}
