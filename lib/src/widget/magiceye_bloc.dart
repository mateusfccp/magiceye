import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../exceptions/magiceye_exception.dart';

class Cameras {
  final Option<CameraDescription> back;
  final Option<CameraDescription> front;
  final Option<CameraDescription> external;

  bool get hasCameras => back.isSome() || front.isSome() || external.isSome();

  const Cameras({
    this.back = const None(),
    this.front = const None(),
    this.external = const None(),
  });

  Cameras copyWith({
    Option<CameraDescription> back,
    Option<CameraDescription> front,
    Option<CameraDescription> external,
  }) =>
      Cameras(
        back: back ?? this.back,
        front: front ?? this.front,
        external: external ?? this.external,
      );

  Cameras update(CameraDescription camera) {
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

class MagicEyeBloc {
  final controller =
      BehaviorSubject<Option<CameraController>>.seeded(const None());

  final _cameras = BehaviorSubject.seeded(const Cameras());

  /// The resolution that will be used on the camera.
  ///
  /// Defaults to the maximum resolution.
  final ResolutionPreset resolutionPreset;

  /// The camera direction that will be used when first opened.
  final CameraLensDirection defaultDirection;

  MagicEyeBloc({
    @required this.resolutionPreset,
    @required this.defaultDirection,
  });

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
  Future<Either<MagicEyeException, Unit>> initialize() async {
    // Get all cameras from the camera plugin
    final cameras = await availableCameras();

    // Map all available cameras to the camera object
    _cameras.add(
      cameras.fold<Cameras>(
        const Cameras(),
        (value, element) => value.update(element),
      ),
    );

    if (!_cameras.value.hasCameras) {
      return const Left(NoCameraAvailable());
    }

    // Deal with the disposal of the controller resources everytime the controller changes
    controller.pairwise().listen(
          (controllers) => controllers.first.map(
            (controller) {
              // Delay the dispose of the controller until the next frame
              SchedulerBinding.instance
                  .addPostFrameCallback((_) => controller.dispose);
            },
          ),
        );

    // Set the initial camera
    return _cameras.value.get(defaultDirection).fold(
          () => const Left(DefaultCameraNotAvailable()),
          (camera) => _setCamera(camera),
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
      () => const Left(CameraUninitialized()),
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
            return Right(path);
          } on CameraException catch (error) {
            return Left(
              InternalException(error),
            );
          }
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
  Future<Either<MagicEyeException, Unit>> selectCamera(
    CameraLensDirection cameraLensDirection,
  ) async =>
      _cameras.value.get(cameraLensDirection).fold(
            () => Left(CameraNotAvailable(cameraLensDirection)),
            (description) => _setCamera(description),
          );

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  Future<Either<MagicEyeException, Unit>> switchCamera() async =>
      controller.value.fold(
        () => Left(const CameraUninitialized()),
        (controller) => selectCamera(
            controller.description.lensDirection == CameraLensDirection.back
                ? CameraLensDirection.front
                : CameraLensDirection.back),
      );

  Future<Either<MagicEyeException, Unit>> _setCamera(
      CameraDescription camera) async {
    // Create new controller for [camera]
    final controller = CameraController(camera, resolutionPreset);

    try {
      await controller.initialize();
      this.controller.add(Some(controller));
      return Right(unit);
    } on CameraException catch (error) {
      return Left(
        InternalException(error),
      );
    }
  }

  /// Releases the resources of the BLoC.
  void dispose() {
    controller.value.forEach((controller) => controller.dispose());
    controller.close();
  }

  Future<Either<MagicEyeException, Unit>> refreshCamera() =>
      controller.value
          .map((controller) => controller.description)
          .map(_setCamera) |
      Future.value(const Right(unit));
}
