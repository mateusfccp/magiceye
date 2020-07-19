import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';

import '../exceptions/magiceye_exception.dart';

/// The context provided to MagicEye control layers.
///
/// The context allows the layer to get the provided parameters on MagicEye creation,
/// as well as the methods necessary to take photos and handle MagicEye.
abstract class LayerContext {
  const LayerContext._();

  /// The cameras this camera is allowed to access.
  Set<CameraLensDirection> get allowedCameras;

  /// Selects the first camera that matches the given [cameraLensDirection] and optionally returns an error.
  ///
  /// If the given [cameraLensDirection] is not allowed by this, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the selection succeeds, returns [None].
  Unit Function(CameraLensDirection) get selectCamera;

  /// Switches from back camera to front camera, and vice-versa.
  ///
  /// If the direction to switch is invalid, returns
  /// [Some<UnallowedDirectionError>].
  ///
  /// If the switchs succeeds, returns [None].
  Unit Function() get switchCamera;

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
  Future<Either<MagicEyeException, String>> Function() get takePicture;
}
