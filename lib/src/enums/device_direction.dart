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

double toRadians(DeviceDirection direction) =>
  toDegrees(direction) * pi / 180;

int toDegrees(DeviceDirection direction) {
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
    case DeviceDirection.unknown:
      return 0;
      break;
  }

  return 0;
}
