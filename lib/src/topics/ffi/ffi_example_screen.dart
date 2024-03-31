// Copyright (c) 2024 Mostafijul Islam
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/material.dart';

int slowFib(int n) => n <= 2 ? 1 : slowFib(n - 1) + slowFib(n - 2);
int testingValue = 0;
void _isolateFunction(SendPort parentsSendPort) {
  final internalReceivePort = ReceivePort();
  parentsSendPort.send(internalReceivePort.sendPort);
  internalReceivePortListener(message) async {
    if (message is int) {
      final time = DateTime.now();
      for (int i = 1; i <= message; i++) {
        final total = i * (i + 1) / 2;
        if (total < 1) return [1];
        final prev = i - 1;
        final prevTotal = prev * (prev + 1) / 2;
        final newStart = (prevTotal + 1).toInt();
        List<int> finalList = [];
        for (int i = newStart; i <= total; i++) {
          testingValue++;
          log("TestingValueInsideIsolate: $testingValue");
          finalList.add(await Isolate.run(
            () => slowFib(i),
          ));
        }
        log("Time Taken for row($i) generation : ${DateTime.now().difference(time)}");
        parentsSendPort.send(finalList);
      }
    }
  }

  internalReceivePort.listen(internalReceivePortListener);
}

class FFIWithRustDemoScreen extends StatefulWidget {
  const FFIWithRustDemoScreen({super.key});

  @override
  State<FFIWithRustDemoScreen> createState() => _FFIWithRustDemoScreenState();
}

class _FFIWithRustDemoScreenState extends State<FFIWithRustDemoScreen> {
  late final ReceivePort _rcvPort;
  late final Isolate _actualIsolate;
  late final _sendPortCompleter = Completer<SendPort>();

  List<List<int>> fibList = [];

  @override
  void initState() {
    super.initState();
    _initialization();
  }

  void _initialization() async {
    try {
      _rcvPort = ReceivePort();
      _actualIsolate = await Isolate.spawn<SendPort>(
        _isolateFunction,
        _rcvPort.sendPort,
        errorsAreFatal: true,
        debugName: "InitialIsolate",
      );
      _rcvPort.listen(_receiveListener);
      final sendPort = await _sendPortCompleter.future;
      sendPort.send(13);
    } catch (e, s) {
      log("#InitializationError", error: e, stackTrace: s);
    }
  }

  _receiveListener(message) {
    if (message is SendPort) {
      _sendPortCompleter.complete(message);
    }
    if (message is List<int>) {
      setState(() {
        fibList.add(message);
      });
    }
  }

  @override
  void dispose() {
    _actualIsolate.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("TestingValueInsideBuild : $testingValue");
    final textPainter = Theme.of(context).textTheme;
    return Scaffold(
      body: InteractiveViewer(
        minScale: 0.0001,
        maxScale: 100,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: SizedBox.fromSize(
          size: MediaQuery.sizeOf(context),
          child: CustomPaint(
            painter: ArtPainterFromIsolate(
              fibList: fibList,
              textStyle: textPainter.bodyMedium!,
            ),
          ),
        ),
      ),
    );
  }
}

typedef BallConfig = ({TextPainter ballPainter, double radius});

class ArtPainterFromIsolate extends CustomPainter {
  final TextStyle textStyle;
  final List<List<int>> fibList;
  ArtPainterFromIsolate({
    super.repaint,
    required this.fibList,
    required this.textStyle,
  });

  final textPadding = 12;
  final horizontalPadding = 10;
  final circlePaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    double yc = size.height - (textPadding);
    final xc = (size.width / 2);

    for (var element in fibList) {
      double biggest = 0;
      List<BallConfig> horizontalBallList = [];
      for (int element in element) {
        final ballConfig = __getCircleConfig(canvas, element);
        horizontalBallList.add(ballConfig);
        if (ballConfig.radius > biggest) {
          biggest = ballConfig.radius;
        }
      }
      final lineWidth = horizontalBallList.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.radius * 2) + horizontalPadding,
      );
      double startX = xc - (lineWidth / 2);
      for (BallConfig x in horizontalBallList) {
        final moveX = x.radius + (horizontalPadding / 2);
        final c = Offset(startX + moveX, yc - x.radius);
        canvas.drawCircle(c, x.radius, circlePaint);
        x.ballPainter.paint(
          canvas,
          c.translate(
            -(x.ballPainter.width / 2),
            -(x.ballPainter.height / 2),
          ),
        );
        startX += (moveX * 2);
      }

      yc -= ((biggest * 2) + (textPadding * 2));
    }
  }

  BallConfig __getCircleConfig(Canvas canvas, int number) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )
      ..text = TextSpan(
        text: number.toString(),
        style: textStyle,
      )
      ..layout(maxWidth: 250);

    final minRad = math.max(textPainter.height, textPainter.width);
    return (ballPainter: textPainter, radius: minRad);
  }

  @override
  bool shouldRepaint(covariant ArtPainterFromIsolate oldDelegate) {
    return true;
  }
}
