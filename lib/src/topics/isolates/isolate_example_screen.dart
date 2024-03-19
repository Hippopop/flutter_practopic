// Copyright (c) 2024 Mostafijul Islam
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void _isolateFunction(SendPort parentsSendPort) {
  final internalReceivePort = ReceivePort();
  parentsSendPort.send(internalReceivePort.sendPort);
  internalReceivePortListener(message) {
    if (message is int) {
      print("Received Value Inside Isolate : $message");
      parentsSendPort.send(List.generate(
        message,
        (index) => index,
      ));
    }
  }

  internalReceivePort.listen(internalReceivePortListener);
}

class FlutterIsolateDemoScreen extends StatefulWidget {
  const FlutterIsolateDemoScreen({super.key});

  @override
  State<FlutterIsolateDemoScreen> createState() =>
      _FlutterIsolateDemoScreenState();
}

class _FlutterIsolateDemoScreenState extends State<FlutterIsolateDemoScreen> {
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
      sendPort.send(5);
    } catch (e, s) {
      log("#InitializationError", error: e, stackTrace: s);
    }
  }

  _receiveListener(message) {
    if (message is SendPort) {
      _sendPortCompleter.complete(message);
    }
    if (message is List<int>) {
      print("Received Value From Isolate : $message");
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
    print("Building : $fibList");
    final textPainter = Theme.of(context).textTheme;
    return Scaffold(
      body: SizedBox.expand(
        child: CustomPaint(
          painter: ArtPainterFromIsolate(
            fibList: fibList,
            textStyle: textPainter.bodyMedium!,
          ),
        ),
      ),
    );
  }
}

class ArtPainterFromIsolate extends CustomPainter {
  final TextStyle textStyle;
  final List<List<int>> fibList;
  ArtPainterFromIsolate({
    super.repaint,
    required this.fibList,
    required this.textStyle,
  });

  final textPadding = 12;
  final circlePaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    double yc = size.height - (textPadding);
    final xc = (size.width / 2);

    fibList.forEach((element) {
      element.forEach((element) {
        final drawBallWidth = __paintSingleBallReturnDiameter(
          canvas,
          element,
          Offset(xc, yc),
        );
        yc -= (drawBallWidth + (textPadding * 2));
      });
    });
  }

  double __paintSingleBallReturnDiameter(
      Canvas canvas, int number, Offset start) {
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

    final center = Offset(start.dx, start.dy - minRad);

    canvas.drawCircle(center, minRad, circlePaint);
    textPainter.paint(
      canvas,
      center.translate(
        -(textPainter.width / 2),
        -(textPainter.height / 2),
      ),
    );
    return minRad * 2;
  }

  @override
  bool shouldRepaint(covariant ArtPainterFromIsolate oldDelegate) {
    return true /* oldDelegate.fibList.first.length != fibList.first.length */;
  }
}
