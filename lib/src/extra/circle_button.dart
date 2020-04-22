import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/device_direction.dart';
import 'circle.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  final BehaviorSubject<DeviceDirection> orientationStream;

  const CircleButton({
    Key key,
    @required this.icon,
    this.onPressed,
    this.orientationStream,
  })  : assert(icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var orientations = Tuple2(0, 0);

    return Circle(
      radius: 25,
      child: StreamBuilder<DeviceDirection>(
        initialData: orientationStream?.value ?? DeviceDirection.portrait,
        stream: orientationStream ?? Stream.value(DeviceDirection.portrait),
        builder: (context, snapshot) {
          final newOrientation = snapshot.data.degrees.toInt();

          orientations = Tuple2(
            orientations.value2,
            newOrientation,
          );

          return TweenAnimationBuilder<int>(
            curve: Curves.bounceOut,
            duration: Duration(milliseconds: 500),
            tween:
                IntTween(begin: orientations.value1, end: orientations.value2),
            builder: (context, rotation, child) => Transform.rotate(
              angle: rotation * pi / 180,
              child: child,
            ),
            child: IconButton(
              color: Colors.white,
              icon: Icon(icon),
              onPressed: onPressed,
            ),
          );
        },
      ),
    );
  }
}
