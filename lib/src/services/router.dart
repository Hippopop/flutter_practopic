import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/topics/animation/circle_button_onboard_animation.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/ripple_example.dart';
import 'package:flutter_practopic/src/topics/fragment_shader/examples/demo_shader_one/transparent_demo.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: "/",
    pageBuilder: (context, state) => CustomTransitionPage(
      child: const TransparentDemoPage(),
      transitionDuration: Duration(seconds: 2),
      reverseTransitionDuration: Duration(seconds: 2),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
            animation: animation,
            builder: (context, __) {
              print(
                  "${child.runtimeType} Root forward value => ${animation.value}");
              print(
                  "${child.runtimeType} Root backward value => ${secondaryAnimation.value}");
              return ShaderBuilder(
                (context, shader, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedSampler(
                      (image, size, canvas) {
                        print(animation.value);
                        TransparentShaderHelper.configureShader(
                          shader,
                          size,
                          image,
                          image,
                          time: 1.55 + (animation.value * 3.15),
                          pointer: Offset.zero,
                        );
                        TransparentShaderHelper.drawShaderRect(
                            shader, size, canvas);
                      },
                      child: child,
                    ),
                  );
                },
                assetKey: "shaders/image_flip.frag",
              );
            });
      },
    ),
  ),
  GoRoute(
    path: "/animation",
    pageBuilder: (context, state) => CustomTransitionPage(
      child: const RippleDemoPage(),
      transitionDuration: Duration(seconds: 2),
      reverseTransitionDuration: Duration(seconds: 2),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
            animation: animation,
            builder: (context, __) {
              print("Second forward value => ${animation.value}");
              print("Second backward value => ${secondaryAnimation.value}");
              return ShaderBuilder(
                (context, shader, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedSampler(
                      (image, size, canvas) {
                        print(animation.value);
                        TransparentShaderHelper.configureShader(
                          shader,
                          size,
                          image,
                          image,
                          time: 1.55 + (animation.value * 3.15),
                          pointer: Offset.zero,
                        );
                        TransparentShaderHelper.drawShaderRect(
                            shader, size, canvas);
                      },
                      child: child,
                    ),
                  );
                },
                assetKey: "shaders/image_flip.frag",
              );
            });
      },
    ),
  ),
]);
