// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024 Mostafijul Islam
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'package:flutter/material.dart';

extension ListHelper<T> on List<T> {
  T? rotatedIndexedItem(int currentIndex) {
    if (isEmpty) return null;
    final maxIndex = length - 1;
    if (currentIndex <= maxIndex) return this[currentIndex];
    final value = currentIndex % length;
    return this[value];
  }
}

class CircleButtonOnboardAnimation extends StatefulWidget {
  const CircleButtonOnboardAnimation({
    super.key,
  });
  @override
  State<CircleButtonOnboardAnimation> createState() =>
      _CircleButtonOnboardAnimationState();
}

class _CircleButtonOnboardAnimationState
    extends State<CircleButtonOnboardAnimation>
    with SingleTickerProviderStateMixin {
  List<({Color page, Color fab})> _pageList = [
    (page: Colors.green, fab: Colors.white),
    (page: Colors.black, fab: Colors.red),
    (page: Colors.purple, fab: Colors.lightGreen),
  ];

  late final AnimationController _animationController;
  late final pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    pageController.addListener(() {
      if (pageController.hasClients) {
        setState(() {
          final leftPercentage =
              ((pageController.page ?? 0).ceil() - (pageController.page ?? 0));
          pageOffset = 1 - leftPercentage.toDouble();
        });
      }
    });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

/*   Animation<double> get _fabFadeInAnimation => {}
      /* Tween<double>(begin: 1, end: 0).animate(TwiceAnimation(
        parent: _animationController,
        firstInterval: Interval(0.0, 0.25),
        secondInterval: Interval(0.75, 1),
        firstTween: Tween<double>(begin: 1, end: 0),
        nextTween: Tween<double>(begin: 0, end: 1),
      )
/*         AnimationMax(
          Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.25),
            ),
          ),
          Tween<double>(begin: 1, end: 0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.75, 1),
            ),
          ),
        ), */
          ) */
      ; */

  double pageOffset = 0;

  double get _fabOpacity {
    double opacity = 0;
    if (pageOffset >= 0 && pageOffset <= 0.1) {
      opacity = (0.1 - pageOffset) / 0.1;
    } else if (pageOffset >= 0.9 && pageOffset <= 1) {
      opacity = 1 - ((0.1 - (pageOffset - 0.9)) / 0.1);
    }
    return opacity;
  }

  Animation<double> get _colorTransition => Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.35, 0.65),
        ),
      );

  _startAnimation() {
    final ticker = _animationController.forward();
    ticker.whenCompleteOrCancel(() {
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: pageController,
        builder: (context, child) {
          return Center(
            child: PageView.builder(
              pageSnapping: true,
              controller: pageController,
              clipBehavior: Clip.hardEdge,
              itemBuilder: (context, index) {
                final fabDimension = 56.0 - (pageOffset * 20);
                final screenSize = MediaQuery.sizeOf(context);
                final fabOffset =
                    Offset(screenSize.width / 2, screenSize.height * 0.75);
                final fabRect = Rect.fromCenter(
                  center: fabOffset,
                  width: fabDimension,
                  height: fabDimension,
                );

                final currentPage = _pageList.rotatedIndexedItem(index);
                final nextPage = _pageList.rotatedIndexedItem(index + 1);
                return SizedBox.fromSize(
                  size: screenSize,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 10,
                          color: Colors.blue,
                        ),
                      ),
                      child: LayoutBuilder(builder: (context, c) {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: c.biggest,
                              painter: CircleOnboardAnimationPainter(
                                fabRect: fabRect,
                                offset: pageOffset,
                                fabColorSet: (
                                  current: currentPage!.fab,
                                  next: nextPage!.fab
                                ),
                                bgColorSet: (
                                  current: currentPage.page,
                                  next: nextPage.page
                                ),
                              ),
                            ),
                            Positioned.fromRect(
                              rect: fabRect,
                              child: Opacity(
                                opacity: _fabOpacity,
                                child: FloatingActionButton(
                                  backgroundColor: currentPage.fab,
                                  onPressed: () {
                                    pageController.nextPage(
                                      curve: Curves.ease,
                                      duration: const Duration(seconds: 8),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CircleOnboardAnimationPainter extends CustomPainter {
  final double offset;
  final Rect fabRect;
  final ({Color current, Color next}) bgColorSet;
  final ({Color current, Color next}) fabColorSet;
  CircleOnboardAnimationPainter({
    required this.offset,
    required this.fabRect,
    required this.bgColorSet,
    required this.fabColorSet,
  });

  Paint get currentCirclePaint => Paint()..color = fabColorSet.current;
  Paint get nextCirclePaint => Paint()..color = fabColorSet.next;
  Paint get currentPagePaint => Paint()..color = bgColorSet.current;
  Paint get nextPagePaint => Paint()..color = fabColorSet.next;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.clipRect(
      Rect.fromCenter(center: c, width: size.width, height: size.height),
    );
    canvas.drawPaint(currentPagePaint);
    _drawCircle(canvas, size, c);
  }

  @override
  bool shouldRepaint(covariant CircleOnboardAnimationPainter oldDelegate) {
    return true;
  }

  void _drawCircle(Canvas canvas, Size size, Offset center) {
    if (offset > 0.1 && offset < 0.9) {
      final raw = offset - 0.1;
      final percentage = (raw * 1.25) * 100;
      if (percentage < 50) {
        final newRad = (size.height * 2) * percentage;
        final newCenter =
            Offset(fabRect.centerLeft.dx + newRad, fabRect.center.dy);
        canvas.drawCircle(
          newCenter,
          newRad,
          currentCirclePaint,
        );
      } else {
        final newPercentage = 100 - percentage;
        final newRad = (size.height * 2) * newPercentage;
        final newCenter =
            Offset((fabRect.centerRight.dx - newRad), fabRect.center.dy);
        canvas.drawCircle(
          newCenter,
          newRad,
          currentCirclePaint,
        );
      }
    } else {
      canvas.drawCircle(
        fabRect.center,
        (fabRect.shortestSide / 2) - 10,
        currentCirclePaint,
      );
    }
  }
}

// Just mixed the systems of [CompoundAnimation] and [CurvedAnimation].
class TwiceAnimation extends CompoundAnimation<double>
    with AnimationWithParentMixin {
  TwiceAnimation({
    required Tween<double> firstTween,
    required Tween<double> nextTween,
    required this.parent,
    required this.firstInterval,
    required this.secondInterval,
  }) : super(
          first: firstTween.animate(
            CurvedAnimation(
              parent: parent,
              curve: firstInterval,
            ),
          ),
          next: nextTween.animate(
            CurvedAnimation(
              parent: parent,
              curve: secondInterval,
            ),
          ),
        ) {
    _updateCurveDirection(parent.status);
    parent.addStatusListener(_updateCurveDirection);
  }
  @override
  final Animation<double> parent;
  Interval firstInterval;
  Interval secondInterval;

  @override
  get value {
    Interval interval = firstInterval;
    Interval reRunInterval = secondInterval;
    if (!_useForwardCurve) {
      interval = interval.flipped as Interval;
      reRunInterval = reRunInterval.flipped as Interval;
    }

    final double t = parent.value;
    final secondPhase = (reRunInterval.begin < t);
    final currentUsingCurve = secondPhase ? reRunInterval : interval;
    final animation = secondPhase ? next : first;
    if (t == 0.0 || t == 1.0) {
      assert(() {
        final double transformedValue = currentUsingCurve.transform(t);
        final double roundedTransformedValue =
            transformedValue.round().toDouble();
        if (roundedTransformedValue != t) {
          throw FlutterError(
            'Invalid curve endpoint at $t.\n'
            'Curves must map 0.0 to near zero and 1.0 to near one but '
            '${currentUsingCurve.runtimeType} mapped $t to $transformedValue, which '
            'is near $roundedTransformedValue.',
          );
        }
        return true;
      }());
      return t;
    }

    return (animation.value);
  }

  AnimationStatus? _curveDirection;

  bool get _useForwardCurve {
    return (_curveDirection ?? parent.status) != AnimationStatus.reverse;
  }

  void _updateCurveDirection(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        _curveDirection = null;
      case AnimationStatus.forward:
        _curveDirection ??= AnimationStatus.forward;
      case AnimationStatus.reverse:
        _curveDirection ??= AnimationStatus.reverse;
    }
  }
}
