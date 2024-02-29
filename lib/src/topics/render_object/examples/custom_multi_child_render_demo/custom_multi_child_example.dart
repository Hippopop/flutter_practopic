import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomMultiChildRenderBoxExample extends StatelessWidget {
  const CustomMultiChildRenderBoxExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "MultiChildRenderWidget Demo",
        ),
      ),
      body: CustomColumn(
        children: [
          CustomExpanded(
            flex: 4,
            child: Image.network(
              "",
            ),
          ),
          Text(
            "This is a custom column.",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            "Made By - Mostafijul Islam.",
          ),
          const CustomSpacer(),
        ],
      ),
    );
  }
}

// Demo Start
class CustomColumnParentData extends ContainerBoxParentData<RenderBox> {
  int flex;
  CustomColumnParentData({
    this.flex = 0,
  });
}

class CustomColumn extends MultiChildRenderObjectWidget {
  const CustomColumn({super.key, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomColumnRenderBox();
  }
}

class CustomColumnRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CustomColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomColumnParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CustomColumnParentData) {
      child.parentData = CustomColumnParentData();
    }
  }

  Size _getSizeAndLayout({
    required BoxConstraints constraints,
    bool isDry = false,
  }) {
    RenderBox? currentChild = firstChild;
    //For flex.
    int totalFlex = 0;
    RenderBox? lastFlexChild;

    double width = 0, height = 0;
    while (currentChild != null) {
      final parentData = currentChild.parentData as CustomColumnParentData;
      /* Do layout for fixed sized widgets (Defining children size)*/
      if (parentData.flex > 0) {
        totalFlex += parentData.flex;
        lastFlexChild = currentChild;
      } else {
        late final Size childSize;
        if (isDry) {
          childSize = currentChild.getDryLayout(
            BoxConstraints(
              maxWidth: constraints.maxWidth,
            ),
          );
        } else {
          // Actually layout cz this is calling from a non dry function!
          currentChild.layout(
            BoxConstraints(maxWidth: constraints.maxWidth),
            parentUsesSize: true,
          );
          childSize = currentChild.size;
        }
        height += childSize.height;
        width = max(width, childSize.width);
      }
      // end.
      currentChild = parentData.nextSibling;
    }

    /* Now set the flex sizes */
    if (totalFlex >= 0) {
      currentChild = lastFlexChild;
      final singleFlexHeight = (constraints.maxHeight - height) / totalFlex;
      debugPrint(
          "Total flex : $totalFlex, Flex height : $singleFlexHeight, Max height : ${constraints.maxHeight}, height : $height");
      while (currentChild != null) {
        final parentData = currentChild.parentData as CustomColumnParentData;
        if (parentData.flex > 0) {
          late final Size childSize;
          final flexHeight = singleFlexHeight * parentData.flex;
          if (isDry) {
            childSize = currentChild.getDryLayout(
              BoxConstraints(
                minHeight: flexHeight,
                maxHeight: flexHeight,
              ),
            );
          } else {
            // Actually layout cz this is calling from a non dry function!
            currentChild.layout(
              BoxConstraints(
                minHeight: flexHeight,
                maxHeight: flexHeight,
              ),
              parentUsesSize: true,
            );
            childSize = currentChild.size;
          }

          height += childSize.height;
          width = max(width, childSize.width);
        }
        // end.
        currentChild = parentData.previousSibling;
      }
    }

    return Size(width, height);
  }

  @override
  void performLayout() {
    /* Layout all the children. (Layout process will be done. SO not dry.) */
    final x = _getSizeAndLayout(constraints: constraints);
    size = x;

    RenderBox? currentChild = firstChild;
    Offset startingOffset = Offset.zero;
    while (currentChild != null) {
      final parentData = currentChild.parentData as CustomColumnParentData;
      /* Do Position, basically setting offset!(Regarding the spacers size)*/
      parentData.offset = Offset(0, startingOffset.dy);
      startingOffset += Offset(0, currentChild.size.height);
      // end.
      currentChild = parentData.nextSibling;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _getSizeAndLayout(
      isDry: true,
      constraints: constraints,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class CustomExpanded extends ParentDataWidget<CustomColumnParentData> {
  final int flex;

  const CustomExpanded({
    super.key,
    this.flex = 1,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as CustomColumnParentData;

    if (parentData.flex != flex) {
      parentData.flex = flex;
      final targetObject = renderObject.parent;
      if (targetObject is RenderObject) {
        targetObject.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CustomColumnParentData;
}

class CustomSpacer extends StatelessWidget {
  const CustomSpacer({
    this.flex = 1,
    super.key,
  });

  final int flex;

  @override
  Widget build(BuildContext context) {
    return CustomExpanded(
      flex: flex,
      child: const SizedBox.shrink(),
    );
  }
}
