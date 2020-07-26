import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import '../core/enums/camera.dart';
import '../core/enums/resolution.dart';
import '../core/exceptions/magiceye_exception.dart';
import '../interfaces/magiceye_camera.dart';
import '../widget/magiceye_controller.dart';

const Map<Camera, CameraLensDirection> _cameraToCameraLensDirection = {
  Camera.BackCamera: CameraLensDirection.back,
  Camera.FrontCamera: CameraLensDirection.front,
  Camera.ExternalCamera: CameraLensDirection.external,
};

const Map<Resolution, ResolutionPreset> _resolutionToResolutionPreset = {
  Resolution.Low: ResolutionPreset.low,
  Resolution.Medium: ResolutionPreset.medium,
  Resolution.High: ResolutionPreset.high,
  Resolution.VeryHigh: ResolutionPreset.veryHigh,
  Resolution.UltraHigh: ResolutionPreset.ultraHigh,
  Resolution.Max: ResolutionPreset.max,
};

class MagicEyeCameraImpl implements MagicEyeCamera {
  final _cameraController =
      BehaviorSubject<Option<CameraController>>.seeded(const None());

  final _cameras = BehaviorSubject.seeded(const _Cameras());
  final _initializer = Completer<void>();

  @override
  Future<void> get initializer => _initializer.future;

  @override
  Widget get preview => _cameraController.value.fold(
        () => const SizedBox(),
        (controller) => CameraPreview(controller),
      );

  /// Initializes the MagicEye bloc.
  ///
  /// The initialization happens in the following order:
  /// * The available cameras are fetched and stored
  /// * A listener is binded to the controller so that it is properly disposed
  /// when changed
  /// * The default camera is set
  ///
  /// Any of the preceding steps may fail. Thus, a
  /// [Either<MagicEyeException, Unit>] is returned when the initialization is
  /// finished with the result of the operation.
  @override
  Future<Either<MagicEyeException, Unit>> initialize(
    MagicEyeController controller,
  ) async {
    // Get all cameras from the camera plugin
    final cameras = await availableCameras();

    // Map all available cameras to the camera object
    _cameras.add(
      cameras.fold<_Cameras>(
        const _Cameras(),
        (value, element) => value.update(element),
      ),
    );

    if (!_cameras.value.hasCameras) {
      return const Left(NoCameraAvailable());
    }

    // Deal with the disposal of the controller resources everytime the controller changes
    _cameraController.pairwise().listen(
          (controllers) => controllers.first.map(
            (controller) {
              // Delay the dispose of the controller until the next frame
              SchedulerBinding.instance
                  .addPostFrameCallback((_) => controller.dispose);
            },
          ),
        );

    final initialCamera =
        _cameraToCameraLensDirection[controller.defaultCamera];

    // Set the initial camera
    return _cameras.value.get(initialCamera).fold(
      () => const Left(DefaultCameraNotAvailable()),
      (camera) {
        _initializer.complete();
        return _setCamera(camera);
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
  @override
  Future<Either<MagicEyeException, String>> takePicture(String path) async {
    // Checks if there is a camera controller or return an error.
    final _controller = _cameraController.value
        .fold<Either<MagicEyeException, CameraController>>(
      () => const Left(CameraUninitialized()),
      (controller) => Right(controller),
    );

    // Takes the picture and saves to the path, or return an error.
    return _controller.fold(
      (error) async => Left(error),
      (controller) async {
        try {
          await controller.takePicture(path);
          return Right(path);
        } on CameraException catch (error) {
          return Left(
            InternalException(error),
          );
        }
      },
    );
  }

  /// Selects the first camera that matches the given [camera] and optionally returns an error.
  ///
  /// If the given [camera] is not allowed by this, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the selection succeeds, returns [None].
  @override
  Future<Either<MagicEyeException, Unit>> selectCamera(
    Camera camera,
  ) async {
    final _camera = _cameraToCameraLensDirection[camera];
    return _cameras.value.get(_camera).fold(
          () => Left(CameraNotAvailable(camera)),
          (description) => _setCamera(description),
        );
  }

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  @override
  Future<Either<MagicEyeException, Unit>> switchCamera() async =>
      _cameraController.value.fold(
        () => Left(const CameraUninitialized()),
        (controller) {
          if (controller.description.lensDirection ==
              CameraLensDirection.external) {
            return const Right(unit);
          } else {
            return selectCamera(
              controller.description.lensDirection == CameraLensDirection.back
                  ? Camera.FrontCamera
                  : Camera.BackCamera,
            );
          }
        },
      );

  Future<Either<MagicEyeException, Unit>> _setCamera(
    CameraDescription camera,
  ) async {
    final resolutionPreset =
        _resolutionToResolutionPreset[null]; // TODO: Resolution problem
    final controller = CameraController(camera, resolutionPreset);

    try {
      await controller.initialize();
      _cameraController.add(Some(controller));
      return Right(unit);
    } on CameraException catch (error) {
      return Left(
        InternalException(error),
      );
    }
  }

  /// Releases the resources of the BLoC.
  @override
  Future<Unit> dispose() async {
    _cameraController.value.forEach((controller) => controller.dispose());
    await _cameraController.close();

    return unit;
  }

  @override
  Future<Either<MagicEyeException, Unit>> refreshCamera() =>
      _cameraController.value
          .map((controller) => controller.description)
          .map(_setCamera) |
      Future.value(const Right(unit));
}

class _Cameras {
  final Option<CameraDescription> back;
  final Option<CameraDescription> front;
  final Option<CameraDescription> external;

  bool get hasCameras => back.isSome() || front.isSome() || external.isSome();

  const _Cameras({
    this.back = const None(),
    this.front = const None(),
    this.external = const None(),
  });

  _Cameras copyWith({
    Option<CameraDescription> back,
    Option<CameraDescription> front,
    Option<CameraDescription> external,
  }) =>
      _Cameras(
        back: back ?? this.back,
        front: front ?? this.front,
        external: external ?? this.external,
      );

  _Cameras update(CameraDescription camera) {
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return copyWith(back: Some(camera));
      case CameraLensDirection.front:
        return copyWith(front: Some(camera));
      case CameraLensDirection.external:
        return copyWith(external: Some(camera));
      default:
        return this;
    }
  }

  Option<CameraDescription> get(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return back;
      case CameraLensDirection.front:
        return front;
      case CameraLensDirection.external:
        return external;
      default:
        return const None();
    }
  }
}
