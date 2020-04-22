import 'dart:math';

/// The device direction.
enum DeviceDirection {
  portrait,
  portraitReversed,
  landscapeLeft,
  landscapeRight,
  unknown
}

/// Extends the DeviceDirection enum with getters that represent the direction's angle.
extension DeviceDirectionAngleExtension on DeviceDirection {
  double _toDegrees(DeviceDirection direction) {
    switch (direction) {
      case DeviceDirection.portrait:
        return 0;
        break;
      case DeviceDirection.portraitReversed:
        return 180;
        break;
      case DeviceDirection.landscapeLeft:
        return 90;
        break;
      case DeviceDirection.landscapeRight:
        return 270;
        break;
      default:
        return 0;
        break;
    }
  }

  /// The direction angle in degrees.
  double get degrees => _toDegrees(this);

  /// The direction angle in radians.
  double get radians => degrees * pi / 180;

  /// The difference, in degrees, between this and [direction].
  ///
  /// When the difference is 180 degrees, the angle returned is positive.
  double difference(DeviceDirection direction) {
    final diff = direction.degrees - degrees;
    if (diff == 270) {
      return -90;
    } else if (diff == -270) {
      return 90;
    } else {
      return diff;
    }
  }
}
