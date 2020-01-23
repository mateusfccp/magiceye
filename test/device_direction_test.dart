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
    'Difference between portrait and landscapeLeft must be 90',
    () {
      expect(
        DeviceDirection.portrait.difference(DeviceDirection.landscapeLeft),
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
    'Difference between portrait and landscapeRight must be -90',
    () {
      expect(
        DeviceDirection.portrait.difference(DeviceDirection.landscapeRight),
        -90,
      );
    },
  );

  // LandscapeLeft
  test(
    'Difference between landscapeLeft and portrait must be -90',
    () {
      expect(
        DeviceDirection.landscapeLeft.difference(DeviceDirection.portrait),
        -90,
      );
    },
  );

  test(
    'Difference between landscapeLeft and landscapeLeft must be 0',
    () {
      expect(
        DeviceDirection.landscapeLeft.difference(DeviceDirection.landscapeLeft),
        0,
      );
    },
  );

  test(
    'Difference between landscapeLeft and portraitReversed must be 90',
    () {
      expect(
        DeviceDirection.landscapeLeft.difference(DeviceDirection.portraitReversed),
        90,
      );
    },
  );

  test(
    'Difference between landscapeLeft and landscapeRight must be 180',
    () {
      expect(
        DeviceDirection.landscapeLeft
            .difference(DeviceDirection.landscapeRight)
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
    'Difference between portraitReversed and landscapeLeft must be -90',
    () {
      expect(
        DeviceDirection.portraitReversed.difference(DeviceDirection.landscapeLeft),
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
    'Difference between portraitReversed and landscapeRight must be 90',
    () {
      expect(
        DeviceDirection.portraitReversed
            .difference(DeviceDirection.landscapeRight),
        90,
      );
    },
  );

  // LandscapeRight
  test(
    'Difference between landscapeRight and portrait must be 90',
    () {
      expect(
        DeviceDirection.landscapeRight.difference(DeviceDirection.portrait),
        90,
      );
    },
  );

  test(
    'Difference between landscapeRight and landscapeLeft must be 180',
    () {
      expect(
        DeviceDirection.landscapeRight
            .difference(DeviceDirection.landscapeLeft)
            .abs(),
        180,
      );
    },
  );

  test(
    'Difference between landscapeRight and portraitReversed must be -90',
    () {
      expect(
        DeviceDirection.landscapeRight
            .difference(DeviceDirection.portraitReversed),
        -90,
      );
    },
  );

  test(
    'Difference between landscapeRight and landscapeRight must be 0',
    () {
      expect(
        DeviceDirection.landscapeRight
            .difference(DeviceDirection.landscapeRight),
        0,
      );
    },
  );
}
