import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:magiceye/src/core/enums/resolution.dart';

import '../core/enums/camera.dart';
import '../core/exceptions/magiceye_exception.dart';

abstract class MagicEyeCamera {
  Resolution get initialResolution;
  Camera get initialCamera;

  Future<void> get initializer;
  Option<Widget> get preview;

  Future<Option<MagicEyeException>> initialize();
  Future<Option<MagicEyeException>> takePicture(String path);
  Future<Option<MagicEyeException>> selectCamera(Camera camera);
  Future<Option<MagicEyeException>> switchCamera();
  Future<Option<MagicEyeException>> refreshCamera();
  Future<Unit> dispose();
}
