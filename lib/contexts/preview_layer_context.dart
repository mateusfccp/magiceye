import 'package:magiceye/enums/device_direction.dart';
import 'package:flutter/foundation.dart';

/// The context provided to MagicEye preview layers.
/// 
/// The context allows the layer to get the provided parameters on MagicEye creation,
/// as well as the device's direction.
class PreviewLayerContext {
  /// The directions this camera is allowed to take photos from.
  final Set<DeviceDirection> allowedDirections;

  /// A stream that emits every change on device's direction.
  final Stream<DeviceDirection> direction;

  const PreviewLayerContext({
    @required this.allowedDirections,
    @required this.direction,
  })  : assert(allowedDirections != null),
        assert(direction != null);
}
