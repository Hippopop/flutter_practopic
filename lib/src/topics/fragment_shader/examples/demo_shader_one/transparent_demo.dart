import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class TransparentDemoPage extends StatefulWidget {
  const TransparentDemoPage({super.key});

  @override
  State<TransparentDemoPage> createState() => _TransparentDemoPageState();
}

class _TransparentDemoPageState extends State<TransparentDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
        final widget = RepaintBoundary(
          key: globalKey,
          child: Image.asset(
            "images/image-1.jpg",
            fit: BoxFit.cover,
          ),
        );

        return Center(
          child: ShaderBuilder(
            (context, shader, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedSampler(
                  (image, size, canvas) {
                    print(_controller.value);
                    TransparentShaderHelper.configureShader(
                      shader,
                      size,
                      image,
                      image,
                      time: _controller.value * 4.65,
                      pointer: _pointer,
                    );
                    TransparentShaderHelper.drawShaderRect(
                        shader, size, canvas);
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
                          onPressed: () {},
                          child: const Text("Let's Check"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            assetKey: "shaders/image_flip.frag",
          ),
        );
      },
    );
  }
}

class TransparentShaderHelper {
  static void configureShader(
    ui.FragmentShader shader,
    ui.Size size,
    ui.Image image,
    ui.Image imageTwo, {
    required double time,
    required Offset pointer,
  }) {
    shader
      ..setFloat(0, size.width) // iResolution
      ..setFloat(1, size.height) // iResolution
      ..setFloat(2, time) // iTime
      ..setImageSampler(0, image) // image
      ..setImageSampler(1, imageTwo); // image
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
