import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

import '../contexts/layer_context.dart';
import '../exceptions/magiceye_exception.dart';
import 'magiceye_bloc.dart';
import 'magiceye_controller.dart';

/// A component that provides access to the devices camera and abstracts it's functions.
///
/// Cameram uses [camera](https://pub.dev/packages/camera) plugin to access the device cameras.
/// Cameram widget provides a camera preview that respects the aspect ratio of the camera.
///
/// MagicEye can be pushed to screen by using the [Navigator].
/// ```dart
/// Navigator.push(
///   MaterialPageRoute<Either<MagicEyeException, String>>(
///     builder: (_) => MagicEye(),
///    ),
/// ).then(
///   (result) => result.fold(
///     (exception) => // Handle exception case
///     (path) => // Handle success case. [path] has the path to the file saved
///   ),
/// );
/// ```
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
class MagicEye extends StatefulWidget {
  /// The widget showed when the camera is still not ready.
  final Widget loadingWidget;

  /// The control layer builder.
  final Widget Function(
    BuildContext,
    LayerContext,
  ) controlLayer;

  /// The preview layer builder.
  final Widget Function(
    BuildContext,
    LayerContext,
  ) previewLayer;

  /// The resolution that will be used on the camera.
  final ResolutionPreset resolutionPreset;

  /// The camera direction that will be used when first opened.
  final CameraLensDirection defaultDirection;

  /// The camera logic component.
  final MagicEyeBloc _bloc;

  /// The alignment of the preview in the stack.
  final AlignmentDirectional previewAlignment;

  /// The widget's controller.
  final MagicEyeController controller;

  /// Creates a MagicEye component.
  MagicEye({
    Key key,
    this.loadingWidget = const CircularProgressIndicator(),
    this.previewLayer,
    this.controlLayer,
    this.resolutionPreset = ResolutionPreset.max,
    this.defaultDirection = CameraLensDirection.back,
    this.previewAlignment = AlignmentDirectional.topCenter,
    this.controller,
  })  : _bloc = MagicEyeBloc(
          resolutionPreset: resolutionPreset,
          defaultDirection: defaultDirection,
        ),
        assert(loadingWidget != null),
        assert(resolutionPreset != null),
        assert(defaultDirection != null);

  // TODO: After push is removed, inject `_MagicEyeState()` directly on `createState()`
  final _state = _MagicEyeState();

  @override
  _MagicEyeState createState() => _state;

  /// Pushes the MagicEye to the screen.
  ///
  /// This is the recommended way to push MagicEye to the screen, as it is simpler and
  /// deals with the widget's disposal.
  ///
  /// It will return [Either] a [Left<MagicEyeException>], which can be handled or thrown by the client,
  /// or a [Right<String>] containing the path to the screenshot taken.
  @Deprecated('Use the Navigator to push MagicEye to your context instead.')
  Future<Either<MagicEyeException, String>> push(BuildContext context) =>
      Navigator.of(context).push<Either<MagicEyeException, String>>(
        MaterialPageRoute(builder: _state.build),
      );
}

class _MagicEyeState extends State<MagicEye> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<Option<CameraController>>(
        stream: widget._bloc.controller,
        initialData: widget._bloc.controller.value,
        builder: (context, snapshot) => snapshot.data.fold<Widget>(
          () => Center(child: widget.loadingWidget),
          (controller) => Stack(
            alignment: widget.previewAlignment,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  children: <Widget>[
                    CameraPreview(controller),
                    widget.previewLayer(
                      context,
                      null, // TODO: LayerContext
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: widget.controlLayer(
                  context,
                  null, // TODO: LayerContext
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget._bloc.refreshCamera();
    super.didChangeAppLifecycleState(state);
  }

  /// Releases the widget's resources.
  @override
  void dispose() {
    super.dispose();
    widget._bloc.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
