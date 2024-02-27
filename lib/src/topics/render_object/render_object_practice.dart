import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/structures.dart';
import 'package:flutter_practopic/src/topics/render_object/examples/custom_multi_child_render_demo/custom_multi_child_example.dart';

class RenderObjectPractice extends StatelessWidget {
  const RenderObjectPractice({super.key});

  @override
  Widget build(BuildContext context) {
    return FrontPageStructure(
      topicColor: Colors.purple.shade100,
      name: "My RenderObjectPractice",
      exampleList: const [
        Example(
          page: CustomMultiChildRenderBoxExample(),
          name: "CustomMultiChildRenderWidget Demo",
        ),
      ],
      linkList: const [],
    );
  }
}
