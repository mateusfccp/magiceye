import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/device_camera.dart';
import '../enums/device_direction.dart';
import '../errors/unallowed_direction_error.dart';
import '../exceptions/magiceye_exception.dart';
import '../widget/magiceye_bloc.dart';

/// The context provided to MagicEye control layers.
///
/// The context allows the layer to get the provided parameters on MagicEye creation,
/// as well as the methods necessary to take photos and handle MagicEye.
class ControlLayerContext {
  /// The directions this camera is allowed to take photos from.
  final Set<DeviceDirection> allowedDirections;

  /// The cameras this camera is allowed to access.
  final Set<DeviceCamera> allowedCameras;

  /// A stream that emits every change on device's direction.
  final BehaviorSubject<DeviceDirection> direction;

  /// Selects the first camera that matches the given [cameraLensDirection] and optionally returns an error.
  ///
  /// If the given [cameraLensDirection] is not allowed by this, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the selection succeeds, returns [None].
  final Option<UnallowedCameraError> Function(DeviceCamera) selectCamera;

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  final Option<UnallowedCameraError> Function() switchCamera;

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
  final Future<Either<MagicEyeException, String>> Function() takePicture;

  ControlLayerContext({
    @required this.allowedCameras,
    @required this.allowedDirections,
    @required MagicEyeBloc bloc,
    @required this.direction,
  })  : assert(allowedCameras != null),
        assert(allowedDirections != null),
        assert(direction != null),
        assert(bloc != null),
        selectCamera = bloc.selectCamera,
        switchCamera = bloc.switchCamera,
        takePicture = bloc.takePicture;
}
