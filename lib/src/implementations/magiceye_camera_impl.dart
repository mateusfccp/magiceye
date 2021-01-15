import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../core/enums/camera.dart';
import '../core/enums/resolution.dart';
import '../core/exceptions/magiceye_exception.dart';
import '../interfaces/magiceye_camera.dart';

const Map<Camera, CameraLensDirection> _cameraToCameraLensDirection = {
  Camera.backCamera: CameraLensDirection.back,
  Camera.frontCamera: CameraLensDirection.front,
  Camera.externalCamera: CameraLensDirection.external,
};

const Map<Resolution, ResolutionPreset> _resolutionToResolutionPreset = {
  Resolution.low: ResolutionPreset.low,
  Resolution.medium: ResolutionPreset.medium,
  Resolution.high: ResolutionPreset.high,
  Resolution.veryHigh: ResolutionPreset.veryHigh,
  Resolution.ultraHigh: ResolutionPreset.ultraHigh,
  Resolution.max: ResolutionPreset.max,
};

class MagicEyeCameraImpl implements MagicEyeCamera {
  MagicEyeCameraImpl(
    this.initialResolution,
    this.initialCamera,
  );

  @override
  final Resolution initialResolution;

  @override
  final Camera initialCamera;

  _State state = _initializing;

  final _initializer = Completer<void>();

  @override
  Future<void> get initializer => _initializer.future;

  @override
  Option<Widget> get preview => state.fold(
        initializing: () => None(),
        initialized: (state) => Some(CameraPreview(state.controller)),
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
  /// [Option<MagicEyeException>] is returned when the initialization is
  /// finished with the result of the operation.
  @override
  Future<Option<MagicEyeException>> initialize() async {
    // Get all cameras from the camera plugin
    final cameras = await availableCameras();

    // Map all available cameras to the camera object
    final stateCameras = cameras.fold<_Cameras>(
      const _Cameras(),
      (value, element) => value.update(element),
    );

    if (!stateCameras.hasCamera) {
      return const Some(NoCameraAvailable());
    }

    return stateCameras.get(_cameraToCameraLensDirection[initialCamera]).fold(
      () => const Some(DefaultCameraNotAvailable()),
      (camera) async {
        state = _Initialized(
          cameras: stateCameras,
          camera: camera,
          resolution: initialResolution,
        );

        await (state as _Initialized).controller.initialize();

        _initializer.complete();
        return const None();
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
  Future<Option<MagicEyeException>> takePicture(String path) async {
    await initializer;

    return state.fold(
      initializing: () => const Some(CameraUninitialized()),
      initialized: (state) async {
        try {
          final file = await state.controller.takePicture();
          file.saveTo(path);
          return const None();
        } on CameraException catch (error) {
          return Some(InternalException(error));
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
  Future<Option<MagicEyeException>> selectCamera(
    Camera camera,
  ) async {
    await initializer;

    return state.fold(
      initializing: () => const Some(CameraUninitialized()),
      initialized: (state) async {
        final _camera = _cameraToCameraLensDirection[camera];
        return state.cameras.get(_camera).fold(
          () => Some(CameraNotAvailable(camera)),
          (description) async {
            state = state.copyWith(camera: description);

            try {
              await state.controller.initialize();
              return const None();
            } on CameraException catch (error) {
              return Some(InternalException(error));
            }
          },
        );
      },
    );
  }

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  @override
  Future<Option<MagicEyeException>> switchCamera() async {
    await initializer;

    return state.fold(
      initializing: () => const Some(CameraUninitialized()),
      initialized: (state) async {
        final newCamera = state.controller.description.lensDirection ==
                CameraLensDirection.back
            ? CameraLensDirection.front
            : CameraLensDirection.back;

        return state.cameras.get(newCamera).fold(
          () => Some(CameraNotAvailable(null)), // TODO: Fix null
          (description) {
            state = state.copyWith(camera: description);
            return const None();
          },
        );
      },
    );
  }

  /// Releases the resources of the BLoC.
  @override
  Future<Unit> dispose() async {
    await initializer;

    await (state as _Initialized).controller.dispose();

    return unit;
  }

  @override
  Future<Option<MagicEyeException>> refreshCamera() async => null; //TODO: Fix?
  // _cameraController.value
  //     .map((controller) => controller.description)
  //     .map(_setCamera) |
  // Future.value(const Right(unit));
}

abstract class _State {
  const _State();

  T fold<T>({
    @required T Function() initializing,
    @required T Function(_Initialized state) initialized,
  }) {
    assert(initializing != null);
    assert(initialized != null);

    if (this is _Initializing) {
      return initializing();
    } else if (this is _Initialized) {
      return initialized(this as _Initialized);
    } else {
      // TODO: Improve
      throw Exception();
    }
  }

  Either<MagicEyeException, T> orException<T>(
    T Function(_Initialized state) initialized,
  ) =>
      fold(
        initializing: () => const Left(CameraUninitialized()),
        initialized: (state) => Right(initialized(state)),
      );
}

class _Initializing extends _State {
  const _Initializing();
}

const _initializing = _Initializing();

class _Initialized extends _State {
  final _Cameras cameras;
  final Resolution resolution;
  final CameraDescription camera;

  final CameraController _controller;

  CameraController get controller => _controller;

  _Initialized({
    @required this.cameras,
    @required this.resolution,
    @required this.camera,
  })  : assert(cameras != null),
        assert(resolution != null),
        assert(camera != null),
        _controller = CameraController(
          camera,
          _resolutionToResolutionPreset[resolution],
          enableAudio: false,
        );

  _Initialized copyWith({
    _Cameras cameras,
    Resolution resolution,
    CameraDescription camera,
  }) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _controller.dispose);

    return _Initialized(
      cameras: cameras ?? this.cameras,
      resolution: resolution ?? this.resolution,
      camera: camera ?? this.camera,
    );
  }
}

class _Cameras {
  final Option<CameraDescription> back;
  final Option<CameraDescription> front;
  final Option<CameraDescription> external;

  bool get hasCamera => back.isSome() || front.isSome() || external.isSome();

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
