import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:magiceye/src/widget/magiceye_controller.dart';

import '../core/enums/camera.dart';
import '../core/exceptions/magiceye_exception.dart';

abstract class MagicEyeCamera {
  Future<void> get initializer;
  Widget get preview;

  Future<Either<MagicEyeException, Unit>> initialize(
    MagicEyeController controller,
  );
  Future<Either<MagicEyeException, String>> takePicture(String path);
  Future<Either<MagicEyeException, Unit>> selectCamera(Camera camera);
  Future<Either<MagicEyeException, Unit>> switchCamera();
  Future<Either<MagicEyeException, Unit>> refreshCamera();
  Future<Unit> dispose();
}
