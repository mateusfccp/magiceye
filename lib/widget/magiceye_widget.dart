import 'package:camera/camera.dart';
import 'package:magiceye/contexts/control_layer_context.dart';
import 'package:magiceye/contexts/preview_layer_context.dart';
import 'package:magiceye/enums/device_camera.dart';
import 'package:magiceye/enums/device_direction.dart';
import 'package:magiceye/layers/default_camera_preview_layer.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:rxdart/rxdart.dart';

import '../layers/default_camera_control_layer.dart';
import 'magiceye_bloc.dart';

/// A component that provides access to the devices camera and abstracts it's functions.
///
/// Cameram uses [camera](https://pub.dev/packages/camera) plugin to access the device cameras.
/// Cameram widget provides a camera preview that respects the aspect ratio of the camera.
///
/// MagicEye can be pushed to screen by calling [push].
/// ```dart
/// MagicEye.push(context).then((path) => print("Photo saved to $path"));
/// ```
///
/// If you want a confirmation screen before the path is returned, you may use [pushWithConfirmation] instead.
/// 
/// MagicEye can also be pushed manually with [Navigator.push]. If you do this way, don't forget to [dispose] the
/// component.
///
/// The maximum resolution will be used, unless an alternative [resolutionPreset] is provided.
/// The cameras access and direction can also be limitated throw [allowedCameras] and [allowedDirections].
/// Trying to select a camera not allowed by [allowedCameras] will return a [UnallowedDirectionError].
///
/// If the camera is not yet initialized, [loadingWidget] will be shown in the place of the preview, centered.
///
/// ## Layers
///
/// Although MagicEye may be used as is, you can customize it's [controlLayer] and [previewLayer]. Both receives the
/// necessary context and expects to return a [Widget].
///
/// ### Preview Layer
///
/// The Preview Layer is, usually, used for graphical-only widgets, although it accepts any [Widget]. The canvas is
/// limited to the preview area, so if the preview aspect ratio is different from the device's aspect ratio, the
/// canvas will not include the black area.
/// 
/// MagicEye provide some default preview layers through [PackageLayer]. An example is [PreviewLayer.grid], which
/// shows a grid on the preview to help with the Rule of Thirds.
///
/// To make a custom preview layer, [previewLayer] accepts a [Widget Function(BuildContext, PreviewLayerContext)].
/// [PreviewLayerContext] provides the [allowedDirections] parameter used on MagicEye instatiation. Also, a
/// [direction] stream emits info about the current device orientation.
///
/// ### Control Layer
///
/// The Control Layer is used to render the controls of the camera. Its canvas is the entire device screen.
/// The parameter [controlLayer] is similar to [previewLayer], but provides a [ControlLayerContext] instead, which
/// gives you access to the camera functions like [takePicture].
class MagicEye extends StatelessWidget {
  /// The widget showed when the camera is still not ready.
  final Widget loadingWidget;

  /// The control layer builder.
  final Widget Function(
    BuildContext,
    ControlLayerContext,
  ) controlLayer;

  /// The preview layer builder.
  final Widget Function(
    BuildContext,
    PreviewLayerContext,
  ) previewLayer;

  /// The resolution that will be used on the camera.
  final ResolutionPreset resolutionPreset;

  /// The camera direction that will be used when first opened.
  final DeviceCamera defaultDirection;

  /// The cameras that will be available to the camera.
  final Set<DeviceCamera> allowedCameras;

  /// The camera directions that will be available to the camera.
  final Set<DeviceDirection> allowedDirections;

  final MagicEyeBloc _cameramBloc;
  final PublishSubject<DeviceDirection> _orientation = PublishSubject();

  /// Creates a MagicEye component.
  MagicEye({
    Key key,
    this.loadingWidget = const CircularProgressIndicator(),
    this.controlLayer = defaultCameraControlLayer,
    this.previewLayer = defaultCameraPreviewLayer,
    this.resolutionPreset = ResolutionPreset.max,
    this.defaultDirection = DeviceCamera.back,
    this.allowedCameras = const {
      DeviceCamera.back,
      DeviceCamera.front,
    },
    this.allowedDirections = const {DeviceDirection.portrait},
  }) : this._cameramBloc = MagicEyeBloc(
          resolutionPreset: resolutionPreset,
          defaultDirection: defaultDirection,
          allowedCameras: allowedCameras,
        );

  @override
  Widget build(BuildContext context) => StreamBuilder<Option<CameraController>>(
        stream: _cameramBloc.controller,
        initialData: None(),
        builder: (context, snapshot) => snapshot.data
            .bind<CameraController>((controller) =>
                controller.value.isInitialized ? Some(controller) : None())
            .fold<Widget>(
              () => Center(child: loadingWidget),
              (controller) => NativeDeviceOrientationReader(
                useSensor: true,
                builder: (context) {
                  _orientation.add(DeviceDirection.values[
                      NativeDeviceOrientationReader.orientation(context)
                          .index]);

                  return Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: Stack(
                          children: <Widget>[
                            CameraPreview(controller),
                            previewLayer(
                              context,
                              PreviewLayerContext(
                                allowedDirections: allowedDirections,
                                direction: _orientation,
                              ),
                            ),
                          ],
                        ),
                      ),
                      controlLayer(
                        context,
                        ControlLayerContext(
                          allowedCameras: allowedCameras,
                          allowedDirections: allowedDirections,
                          bloc: _cameramBloc,
                          direction: _orientation,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      );

  void dispose() => _cameramBloc.dispose();

  Future<String> push(BuildContext context) => Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: this.build,
        ),
      )
          .then((path) {
        this.dispose();
        return path;
      });
}
