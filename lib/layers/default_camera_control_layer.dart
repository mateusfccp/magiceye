import 'dart:math';
import 'package:magiceye/contexts/control_layer_context.dart';
import 'package:magiceye/enums/device_direction.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

Widget defaultCameraControlLayer(
  BuildContext context,
  ControlLayerContext layerContext,
) =>
    Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _button(
              context: context,
              icon: Icons.arrow_back_ios,
              onPressed: Navigator.pop,
              orientationStream: layerContext.direction,
            ),
            StreamBuilder<DeviceDirection>(
              initialData: DeviceDirection.portrait,
              stream: layerContext.direction,
              builder: (context, snapshot) {
                final bool enabled =
                    layerContext.allowedDirections.contains(snapshot.data);

                return AnimatedCrossFade(
                  duration: Duration(milliseconds: 500),
                  firstCurve: Curves.easeOutQuint,
                  firstChild: _button(
                    context: context,
                    icon: Icons.camera_alt,
                    onPressed: (context) => layerContext.takePicture().then(
                          (path) => path.fold(
                            (error) => print(error),
                            (path) => Navigator.of(context).pop(path),
                          ),
                        ),
                    orientationStream: layerContext.direction,
                  ),
                  secondCurve: Curves.easeOutQuint,
                  secondChild: SizedBox(width: 50, height: 50),
                  crossFadeState: enabled
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                );
              },
            ),
            layerContext.allowedCameras.length > 1
                ? _button(
                    context: context,
                    icon: Icons.cached,
                    onPressed: (_) => layerContext.switchCamera(),
                    orientationStream: layerContext.direction,
                  )
                : SizedBox(width: 50, height: 50),
          ],
        ),
      ),
    );

Widget _button({
  @required BuildContext context,
  @required IconData icon,
  void Function(BuildContext context) onPressed,
  Stream<DeviceDirection> orientationStream,
}) {
  Tuple2<int, int> orientations = Tuple2(0, 0);

  return _circle(
    radius: 25,
    child: StreamBuilder<DeviceDirection>(
      initialData: DeviceDirection.portrait,
      stream: orientationStream,
      builder: (context, snapshot) {
        final int newOrientation = toDegrees(snapshot.data);

        orientations = Tuple2(
          orientations.value1,
          newOrientation,
        );

        return TweenAnimationBuilder(
          curve: Curves.bounceOut,
          duration: Duration(milliseconds: 500),
          tween: IntTween(begin: orientations.value1, end: orientations.value2),
          builder: (context, rotation, child) => Transform.rotate(
            angle: rotation * pi / 180,
            child: child,
          ),
          child: IconButton(
            color: Colors.white,
            icon: Icon(icon),
            onPressed: () => onPressed != null ? onPressed(context) : null,
          ),
        );
      },
    ),
  );
}

Widget _circle({
  @required Widget child,
  @required double radius,
  Color color = Colors.black38,
}) =>
    Container(
      width: radius * 2,
      height: radius * 2,
      child: child,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
