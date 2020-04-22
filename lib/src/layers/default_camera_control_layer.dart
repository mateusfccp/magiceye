import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:magiceye/src/exceptions/magiceye_exception.dart';
import 'package:rxdart/rxdart.dart';

import '../contexts/control_layer_context.dart';
import '../enums/device_direction.dart';
import '../extra/circle_button.dart';

abstract class _CameraState {
  const _CameraState();
}

class _Idle extends _CameraState {
  const _Idle();
}

class _TakingPicture extends _CameraState {
  const _TakingPicture();
}

class _WithPicture extends _CameraState {
  final String path;

  const _WithPicture(this.path);
}

class _WithException extends _CameraState {
  final MagicEyeException exception;

  const _WithException(this.exception);
}

Widget Function(BuildContext, ControlLayerContext) defaultCameraControlLayer() {
  var cameraState = BehaviorSubject<_CameraState>.seeded(_Idle());

  return (context, layerContext) => Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          child: StreamBuilder<_CameraState>(
            initialData: cameraState.value,
            stream: cameraState,
            builder: (context, snapshot) {
              if (snapshot.data is _WithException) {
                cameraState.add(const _Idle());
                SchedulerBinding.instance.addPostFrameCallback(
                  (_) {
                    Navigator.of(context)
                        .pop<Either<MagicEyeException, String>>(
                      Left((snapshot.data as _WithException).exception),
                    );
                  },
                );
                cameraState.close();
              }

              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  if (snapshot.data is _TakingPicture ||
                      snapshot.data is _WithPicture)
                    Container(color: Colors.black),
                  if (snapshot.data is _WithPicture)
                    Center(
                      child: Image.file(
                        File(
                          (snapshot.data as _WithPicture).path,
                        ),
                      ),
                    ),
                  if (snapshot.data is _WithPicture)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _BottomConfirmationButtons(
                        path: (snapshot.data as _WithPicture).path,
                        pathStream: cameraState,
                      ),
                    ),
                  if (snapshot.data is _TakingPicture)
                    Center(child: CircularProgressIndicator()),
                  if (snapshot.data is _Idle)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _BottomPictureButtons(
                        layerContext: layerContext,
                        cameraState: cameraState,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
}

class _BottomPictureButtons extends StatelessWidget {
  final BehaviorSubject<_CameraState> cameraState;
  final ControlLayerContext layerContext;

  const _BottomPictureButtons({
    Key key,
    this.layerContext,
    this.cameraState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CircleButton(
              icon: Icons.arrow_back_ios,
              onPressed: Navigator.of(context).pop,
              orientationStream: layerContext.direction,
            ),
            StreamBuilder<DeviceDirection>(
              initialData: layerContext.direction.value,
              stream: layerContext.direction,
              builder: (context, snapshot) {
                final enabled =
                    layerContext.allowedDirections.contains(snapshot.data);

                return AnimatedCrossFade(
                  duration: Duration(milliseconds: 500),
                  firstCurve: Curves.easeOutQuint,
                  firstChild: CircleButton(
                    icon: Icons.camera_alt,
                    onPressed: () {
                      cameraState.add(const _TakingPicture());

                      layerContext.takePicture().then(
                            (pathOr) => pathOr.fold(
                              (e) => cameraState.add(_WithException(e)),
                              (path) => cameraState.add(_WithPicture(path)),
                            ),
                          );
                    },
                    orientationStream: layerContext.direction,
                  ),
                  secondCurve: Curves.easeOutQuint,
                  secondChild: AbsorbPointer(
                    child: SizedBox(width: 50, height: 50),
                  ),
                  crossFadeState: enabled
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                );
              },
            ),
            layerContext.allowedCameras.length > 1
                ? CircleButton(
                    icon: Icons.cached,
                    onPressed: layerContext.switchCamera,
                    orientationStream: layerContext.direction,
                  )
                : SizedBox(width: 50, height: 50),
          ],
        ),
      );
}

class _BottomConfirmationButtons extends StatelessWidget {
  final String path;
  final BehaviorSubject<_CameraState> pathStream;

  const _BottomConfirmationButtons({
    Key key,
    this.path,
    this.pathStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CircleButton(
              icon: Icons.close,
              onPressed: () {
                final directory = Directory(path);
                directory
                    .delete(recursive: true)
                    .then((_) => pathStream.add(const _Idle()));
              },
            ),
            SizedBox(width: 50, height: 50),
            CircleButton(
              icon: Icons.check,
              onPressed: () {
                pathStream.close();
                Navigator.of(context)
                    .pop<Either<MagicEyeException, String>>(Right(path));
              },
            )
          ],
        ),
      );
}
