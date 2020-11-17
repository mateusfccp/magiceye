![MagicEye](https://raw.githubusercontent.com/mateusfccp/magiceye/master/doc/logo_title.png)

An abstraction on top of flutter camera.

[![Version](https://img.shields.io/pub/v/magiceye)](https://pub.dev/packages/magiceye)
[![Build](https://img.shields.io/github/workflow/status/mateusfccp/magiceye/Flutter)](https://github.com/mateusfccp/magiceye/actions?query=Flutter)
[![License](https://img.shields.io/github/license/mateusfccp/magiceye)](https://www.gnu.org/licenses/gpl-3.0.en.html)

## Features

- Provides the lower level handling of the [camera](https://pub.dev/packages/camera) plugin
  - Handles all camera resources
  - Handle camera status when app activity change
- Can be used out-of-the-box by simply calling `MagicEye().push(context)`
- Can be customized with *layers*
- Come with a few, pre-baked, [*preview layers*](https://pub.dev/documentation/magiceye/latest/magiceye/PreviewLayer-class.html)
- Has a functional API leveraged by [dartz](https://github.com/spebbe/dartz)


## Version compatibility

- Dart: 2.7.0
- Flutter: 1.12.13+hotfix.5 (stable)

See [CHANGELOG.md](https://github.com/mateusfccp/magiceye/blob/master/CHANGELOG.md) for all breaking (and non-breaking) changes.


## Getting started

Add `magiceye` as a dependency in your project:

```yaml
dependencies:
  magiceye: ^0.1.7
```

After this, you should then run `flutter packages upgrade` or update your packages with your IDE/editor funcionalities.

Finally, follow the [camera](https://pub.dev/packages/camera) installations instructions for [iOS](https://github.com/flutter/plugins/tree/master/packages/camera#ios) and [Android](https://github.com/flutter/plugins/tree/master/packages/camera#android).


## Usage

If you want to use MagicEye default camera widget, you can do this by calling [`MagicEye.push`](https://pub.dev/documentation/magiceye/latest/magiceye/MagicEye/push.html):

```dart
Future<Either<MagicEyeException, String>> result = await MagicEye().push(context);
result.fold(
    (exception) => // Handle exception case
    (path) => // Handle success case. [path] has the path to the file saved
);
```

> **Disclaimer:** MagicEye widget can be used with `Navigator.push` instead. However, the disposal of resources won't be handled automatically. Use with caution.

You can customize some functionality of the camera passing parameters to the `MagicEye` constructor. For detailed info, consult its [page on the documentation](https://pub.dev/documentation/magiceye/latest/magiceye/MagicEye-class.html).


## Layers

Although MagicEye may be used as is, you can customize it's `controlLayer` and `previewLayer`. Both receives the necessary context and expects to return a `Widget`.

You can see examples of custom layers in the source:

- [default_control_layer.dart](https://github.com/mateusfccp/magiceye/blob/master/lib/src/layers/default_camera_control_layer.dart)
- [preview_layer.dart](https://github.com/mateusfccp/magiceye/blob/master/lib/src/layers/preview_layer.dart)

In the near future, more and simpler examples will be provided in the [example](https://github.com/mateusfccp/magiceye/tree/master/example).

### Preview Layer

The Preview Layer is, usually, used for graphical-only widgets, although it accepts any `Widget`. The canvas is limited to the preview area, so if the preview aspect ratio is different from the device's aspect ratio, the canvas will not include the black area.

MagicEye provide some default preview layers through [`PreviewLayer`](https://pub.dev/documentation/magiceye/latest/magiceye/PreviewLayer-class.html). An example is [`PreviewLayer.grid`](https://pub.dev/documentation/magiceye/latest/magiceye/PreviewLayer/grid.html), which shows a grid on the preview to help with the Rule of Thirds.

To make a custom preview layer, `previewLayer`  accepts a `Widget Function(BuildContext, PreviewLayerContext)`. [`PreviewLayerContext`](https://pub.dev/documentation/magiceye/latest/magiceye/PreviewLayerContext-class.html) provides the `allowedDirections` parameter used on MagicEye instatiation. Also, a `direction`  stream emits info about the current device orientation.

### Control Layer

The Control Layer is used to render the controls of the camera. Its canvas is the entire device screen. The parameter `controlLayer` is similar to `previewLayer`, but provides a [`ControlLayerContext`](https://pub.dev/documentation/magiceye/latest/magiceye/ControlLayerContext-class.html) instead, which gives you access to the camera functions like [`takePicture`](https://pub.dev/documentation/magiceye/latest/magiceye/ControlLayerContext/takePicture.html).

<hr/>

For bugs or additional info, feel free to [open an issue](https://github.com/mateusfccp/magiceye/issues/new).
