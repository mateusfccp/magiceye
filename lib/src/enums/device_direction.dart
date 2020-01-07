import 'dart:math';

/// The device direction.
/// 
/// [landscape] is the left landscape.
enum DeviceDirection {
  portrait,
  portraitReversed,
  landscape,
  landscapeReversed,
  unknown
}

extension DeviceDirectionAngle on DeviceDirection {
  double _toDegrees(DeviceDirection direction) {
    switch (direction) {
      case DeviceDirection.portrait:
        return 0;
        break;
      case DeviceDirection.portraitReversed:
        return 180;
        break;
      case DeviceDirection.landscape:
        return 90;
        break;
      case DeviceDirection.landscapeReversed:
        return -90;
        break;
      default:
        return 0;
        break;
    }
  }
  
  double get degrees => _toDegrees(this);
  double get radians => this.degrees * pi / 180;
}
