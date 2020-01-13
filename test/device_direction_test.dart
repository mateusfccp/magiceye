import 'package:test/test.dart';
import 'package:magiceye/src/enums/device_direction.dart';

void main() {
  // Portrait
  test(
    'Difference between portrait and portrait must be 0',
    () {
      expect(
        DeviceDirection.portrait.difference(DeviceDirection.portrait),
        0,
      );
    },
  );

  test(
    'Difference between portrait and landscape must be 90',
    () {
      expect(
        DeviceDirection.portrait.difference(DeviceDirection.landscape),
        90,
      );
    },
  );

  test(
    'Difference between portrait and portraitReversed must be 180',
    () {
      expect(
        DeviceDirection.portrait
            .difference(DeviceDirection.portraitReversed)
            .abs(),
        180,
      );
    },
  );

  test(
    'Difference between portrait and landscapeReversed must be -90',
    () {
      expect(
        DeviceDirection.portrait.difference(DeviceDirection.landscapeReversed),
        -90,
      );
    },
  );

  // Landscape
  test(
    'Difference between landscape and portrait must be -90',
    () {
      expect(
        DeviceDirection.landscape.difference(DeviceDirection.portrait),
        -90,
      );
    },
  );

  test(
    'Difference between landscape and landscape must be 0',
    () {
      expect(
        DeviceDirection.landscape.difference(DeviceDirection.landscape),
        0,
      );
    },
  );

  test(
    'Difference between landscape and portraitReversed must be 90',
    () {
      expect(
        DeviceDirection.landscape.difference(DeviceDirection.portraitReversed),
        90,
      );
    },
  );

  test(
    'Difference between landscape and landscapeReversed must be 180',
    () {
      expect(
        DeviceDirection.landscape
            .difference(DeviceDirection.landscapeReversed)
            .abs(),
        180,
      );
    },
  );

  // PortraitReversed
  test(
    'Difference between portraitReversed and portrait must be 180',
    () {
      expect(
        DeviceDirection.portraitReversed
            .difference(DeviceDirection.portrait)
            .abs(),
        180,
      );
    },
  );

  test(
    'Difference between portraitReversed and landscape must be -90',
    () {
      expect(
        DeviceDirection.portraitReversed.difference(DeviceDirection.landscape),
        -90,
      );
    },
  );

  test(
    'Difference between portraitReversed and portraitReversed must be 0',
    () {
      expect(
        DeviceDirection.portraitReversed
            .difference(DeviceDirection.portraitReversed),
        0,
      );
    },
  );

  test(
    'Difference between portraitReversed and landscapeReversed must be 90',
    () {
      expect(
        DeviceDirection.portraitReversed
            .difference(DeviceDirection.landscapeReversed),
        90,
      );
    },
  );

  // LandscapeReversed
  test(
    'Difference between landscapeReversed and portrait must be 90',
    () {
      expect(
        DeviceDirection.landscapeReversed.difference(DeviceDirection.portrait),
        90,
      );
    },
  );

  test(
    'Difference between landscapeReversed and landscape must be 180',
    () {
      expect(
        DeviceDirection.landscapeReversed
            .difference(DeviceDirection.landscape)
            .abs(),
        180,
      );
    },
  );

  test(
    'Difference between landscapeReversed and portraitReversed must be -90',
    () {
      expect(
        DeviceDirection.landscapeReversed
            .difference(DeviceDirection.portraitReversed),
        -90,
      );
    },
  );

  test(
    'Difference between landscapeReversed and landscapeReversed must be 0',
    () {
      expect(
        DeviceDirection.landscapeReversed
            .difference(DeviceDirection.landscapeReversed),
        0,
      );
    },
  );
}
