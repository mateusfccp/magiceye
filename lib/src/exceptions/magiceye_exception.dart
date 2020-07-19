import 'package:magiceye/magiceye.dart';

/// Exception returned when anything wrong happens with MagicEye.
abstract class MagicEyeException implements Exception {}

/// Exception returned when the controller is not initialized.
class CameraUninitialized implements MagicEyeException {
  const CameraUninitialized();
}

/// Exception returned when all three camera directions are not available for
/// the device.
class NoCameraAvailable implements MagicEyeException {
  const NoCameraAvailable();
}

/// Exception returned when the expected default camera direction is not
/// available for the device.
class DefaultCameraNotAvailable implements MagicEyeException {
  const DefaultCameraNotAvailable();
}

/// Exception returned when trying to switch to a [direction] that is
/// not available for the device.
class CameraNotAvailable implements MagicEyeException {
  final CameraLensDirection direction;

  const CameraNotAvailable(this.direction);
}

/// Exception returned when a internal exception is thrown.
///
/// The original thrown exception is available through [source].
class InternalException implements MagicEyeException {
  final Object source;

  const InternalException(this.source);
}
