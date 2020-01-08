import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:magiceye/src/exceptions/magiceye_exception.dart';
import 'package:rxdart/rxdart.dart';

import '../contexts/control_layer_context.dart';
import '../enums/device_direction.dart';
import '../extra/circle_button.dart';

Widget Function(BuildContext, ControlLayerContext) defaultCameraControlLayer() {
  BehaviorSubject<Option<Future<Either<MagicEyeException, String>>>>
      pathStream = BehaviorSubject.seeded(None());
  return (
    BuildContext context,
    ControlLayerContext layerContext,
  ) {
    Widget _bottomPictureButtons(
            BuildContext context, ControlLayerContext layerContext) =>
        Padding(
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
                  final bool enabled =
                      layerContext.allowedDirections.contains(snapshot.data);

                  return AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    firstCurve: Curves.easeOutQuint,
                    firstChild: CircleButton(
                      icon: Icons.camera_alt,
                      onPressed: () => pathStream.add(
                        Some(
                          layerContext.takePicture(),
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
                  ? CircleButton(
                      icon: Icons.cached,
                      onPressed: layerContext.switchCamera,
                      orientationStream: layerContext.direction,
                    )
                  : SizedBox(width: 50, height: 50),
            ],
          ),
        );

    Widget _bottomConfirmationButtons(BuildContext context, String path) =>
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CircleButton(
                icon: Icons.close,
                onPressed: () {
                  final Directory directory = new Directory(path);
                  directory
                      .delete(recursive: true)
                      .then((_) => pathStream.add(None()));
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

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        child: StreamBuilder<Option<Future<Either<MagicEyeException, String>>>>(
          initialData: pathStream.value,
          stream: pathStream,
          builder: (context, snapshot) => snapshot.data.fold(
            () => _bottomPictureButtons(context, layerContext),
            (pathOr) => FutureBuilder<Either<MagicEyeException, String>>(
              future: pathOr,
              builder: (context, snapshot) => Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(color: Colors.black),
                  ...(snapshot.hasData && snapshot.data.isRight()
                      ? [
                          Image.file(
                            File(snapshot.data.getOrElse(() => '')),
                          ),
                          _bottomConfirmationButtons(
                            context,
                            snapshot.data.getOrElse(() => ''),
                          ),
                        ]
                      : [Center(child: CircularProgressIndicator())]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };
}
