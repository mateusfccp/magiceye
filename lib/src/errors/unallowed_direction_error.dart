import '../enums/device_camera.dart';

/// Error thrown when an attempt to select a unallowed camera is made.
class UnallowedCameraError extends Error {
  /// The direction that has been attempted to select.
  final DeviceCamera direction;

  /// A message describing the error.
  String get message => '';

  UnallowedCameraError(this.direction);
}
