import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/device_camera.dart';
import '../errors/unallowed_direction_error.dart';
import '../exceptions/magiceye_exception.dart';

class MagicEyeBloc {
  final controller =
      BehaviorSubject<Option<CameraController>>.seeded(const None());

  Map<DeviceCamera, CameraDescription> _cameras = {
    DeviceCamera.back: null,
    DeviceCamera.front: null,
  };

  /// The resolution that will be used on the camera.
  ///
  /// Defaults to the maximum resolution.
  final ResolutionPreset resolutionPreset;

  /// The camera direction that will be used when first opened.
  final DeviceCamera defaultDirection;

  /// The cameras that will be available to the camera.
  final Set<DeviceCamera> allowedCameras;

  MagicEyeBloc({
    Key key,
    @required this.resolutionPreset,
    @required this.defaultDirection,
    @required this.allowedCameras,
  }) {
    availableCameras().then(
      (cameras) {
        _cameras = {
          DeviceCamera.back: cameras
              .where(
                  (camera) => camera.lensDirection == CameraLensDirection.back)
              .first,
          DeviceCamera.front: cameras
              .where(
                  (camera) => camera.lensDirection == CameraLensDirection.front)
              .first,
        };

        _setCamera(_cameras[defaultDirection]);

        // Deal with the disposal of the controller resources everytime the controller changes
        controller.pairwise().listen(
              (controllers) => controllers.first.fold(
                () {},
                (controller) {
                  // Delay the dispose of the controller until the next frame
                  SchedulerBinding.instance
                      .addPostFrameCallback((_) => controller.dispose);
                },
              ),
            );
      },
    );
  }

  /// Takes a picture with the current camera and returns the picture path or an error.
  ///
  /// If the picture has been successfully taken, a [Right<String>] will be returned with
  /// the path that the image was saved.
  ///
  /// The path is generated with
  /// [path_provider](https://pub.dartlang.org/packages/path_provider), using its [getApplicationDocumentsDirectory]
  /// method, or, if [temporary] is true, using its [getTemporaryDirectory] method.
  ///
  /// If any error happens in the process, a [Left<MagicEyeException>] is returned instead.
  Future<Either<MagicEyeException, String>> takePicture(
      {final bool temporary = false}) async {
    // Checks if there is a camera controller or return an error.
    final _controller =
        controller.value.fold<Either<MagicEyeException, CameraController>>(
      () => Left(
        MagicEyeException(
          message: 'Camera controller not found!',
        ),
      ),
      (controller) => Right(controller),
    );

    // Select the path based on [temporary] parameter.
    final pathFunction =
        temporary ? getTemporaryDirectory : getApplicationDocumentsDirectory;

    // Takes the picture and saves to the path, or return an error.
    return _controller.fold<Future<Either<MagicEyeException, String>>>(
      (error) => Future.value(Left(error)),
      (controller) => pathFunction().then<Either<MagicEyeException, String>>(
        (directory) async {
          final path =
              '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';

          try {
            await controller.takePicture(path);
          } on CameraException catch (error) {
            return Left(
              MagicEyeException(
                message: error.description,
                source: error,
              ),
            );
          }
          return Right(path);
        },
      ),
    );
  }

  /// Selects the first camera that matches the given [cameraLensDirection] and optionally returns an error.
  ///
  /// If the given [cameraLensDirection] is not allowed by this, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the selection succeeds, returns [None].
  Option<UnallowedCameraError> selectCamera(
      final DeviceCamera cameraLensDirection) {
    if (!allowedCameras.contains(cameraLensDirection)) {
      return Some(UnallowedCameraError(cameraLensDirection));
    }

    _setCamera(_cameras[cameraLensDirection]);
    return const None();
  }

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  Option<UnallowedCameraError> switchCamera() => controller.value.fold(
        () => const None(),
        (controller) => selectCamera(
            controller.description.lensDirection == CameraLensDirection.back
                ? DeviceCamera.front
                : DeviceCamera.back),
      );

  void _setCamera(final CameraDescription camera) {
    // Create new controller for [camera]
    final controller = CameraController(camera, resolutionPreset);

    controller.initialize().then((_) => this.controller.add(Some(controller)));
  }

  /// Releases the resources of the BLoC.
  void dispose() {
    controller.value.forEach((controller) => controller.dispose());
    controller.close();
  }

  void refreshCamera() => controller.value.fold(
        () {},
        (controller) => _setCamera(controller.description),
      );
}
