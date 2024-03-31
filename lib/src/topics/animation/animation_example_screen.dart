// Copyright (c) 2024 Mostafijul Islam
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import 'package:flutter/material.dart';
import 'package:flutter_practopic/src/topics/animation/circle_button_onboard_animation.dart';

class AnimationExampleScreen extends StatefulWidget {
  const AnimationExampleScreen({super.key});

  @override
  State<AnimationExampleScreen> createState() => _AnimationExampleScreenState();
}

class _AnimationExampleScreenState extends State<AnimationExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return const CircleButtonOnboardAnimation();
  }
}
