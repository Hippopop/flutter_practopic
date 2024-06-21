import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:go_router/go_router.dart';

class TransparentDemoPage extends StatefulWidget {
  const TransparentDemoPage({super.key});

  @override
  State<TransparentDemoPage> createState() => _TransparentDemoPageState();
}

class _TransparentDemoPageState extends State<TransparentDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double testingValue = 0.0;
  double increment = 0.01;
  bool showRef = false;
  String currentRef = "images/image-1.jpg";
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
      body: FutureBuilder<ui.Image>(
          future: getUsableImage("images/image-2.jpg"),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? PageView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: buildImage(snapshot.data!),
                        ),
                      );
                    },
                  )
                : SizedBox();
          }),
    );
  }

  Offset _pointer = Offset.zero;

  void _updatePointer(PointerEvent details) {
    context.push("/animation");
    // if (_controller.isCompleted) {
    //   _controller.reverse();
    // } else {
    //   _controller.forward();
    // }
    // setState(() {
    //   _pointer = details.localPosition;
    // });
  }

  Widget buildImage(ui.Image secondImage) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FloatingActionButton(
                //   onPressed: () {
                //     setState(() {
                //       increment += 0.025;
                //       print("New testing value : $testingValue");
                //     });
                //   },
                //   child: Icon(
                //     Icons.add,
                //   ),
                // ),
                SizedBox(width: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text("Modify By"),
                        const SizedBox(height: 3),
                        Text(
                          increment.toStringAsFixed(4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // FloatingActionButton(
                //   onPressed: () {
                //     setState(() {
                //       increment -= 0.025;
                //       print("New testing value : $testingValue");
                //     });
                //   },
                //   child: const Icon(
                //     Icons.remove,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                ShaderBuilder(
                  (context, shader, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedSampler(
                        (image, size, canvas) {
                          // print(_controller.value);
                          TransparentShaderHelper.configureShader(
                            shader,
                            size,
                            image,
                            secondImage,
                            time: 1.55 + (_controller.value * 3.15),
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
                                "images/image-1.jpg",
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
                if (showRef)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: GestureDetector(
                        onDoubleTap: () {
                          const refList = [
                            "images/image-1.jpg",
                            "images/image-2.jpg",
                          ];

                          setState(() {
                            currentRef = refList
                                .where((element) => element != currentRef)
                                .first;
                          });
                        },
                        onTap: () => setState(() {
                          showRef = !showRef;
                        }),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            currentRef,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FloatingActionButton(
                //   onPressed: () {
                //     setState(() {
                //       testingValue += increment;
                //       print("New testing value : $testingValue");
                //     });
                //   },
                //   child: Icon(
                //     Icons.add,
                //   ),
                // ),
                SizedBox(width: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      testingValue.toStringAsFixed(4),
                    ),
                  ),
                ),
                SizedBox(width: 24),
                // FloatingActionButton(
                //   onPressed: () {
                //     setState(() {
                //       testingValue -= increment;
                //       print("New testing value : $testingValue");
                //     });
                //   },
                //   child: Icon(
                //     Icons.remove,
                //   ),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }
}

Future<ui.Image> getUsableImage(String imagePath) async {
  final ImageProvider provider = AssetImage(imagePath);
  final imageStream = provider.resolve(const ImageConfiguration());
  final completer = Completer<ImageInfo>();

  imageStream.addListener(ImageStreamListener(
    (image, synchronousCall) {
      completer.complete(image);
    },
  ));

  return (await completer.future).image;
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
