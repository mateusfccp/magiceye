import '../core/enums/camera.dart';
import '../core/enums/resolution.dart';

class MagicEyeController {
  /// The resolution that will be used on the camera.
  ///
  /// Defaults to [Resolution.Max].
  final Resolution resolution;

  /// The camera direction that will be used when first opened.
  ///
  /// Defaults to [Camera.BackCamera].
  final Camera defaultCamera;

  MagicEyeController({
    this.resolution = Resolution.Max,
    this.defaultCamera = Camera.BackCamera,
  });
}
