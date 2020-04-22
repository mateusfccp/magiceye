import 'package:flutter/material.dart';
import 'package:magiceye/magiceye.dart';

typedef PreviewLayerBuilder = Widget Function(
  BuildContext,
  PreviewLayerContext,
);

/// Predefined preview layers to be used on [MagicEye] constructor.
///
/// Example:
/// ```dart
///MaterialPageRoute(
///  builder: (context) => MagicEye(
///    previewLayer: PreviewLayer.circleFocus(scale: 2 / 3),
///  ),
///),
/// ```
abstract class PreviewLayer {
  // This class should not be instantiated.
  factory PreviewLayer._() => null;

  /// Generates a layer that focus on a rectangular area that respects the preview's aspect ratio.
  ///
  /// The [color] parameter defaults to a transparent black, and the focus
  /// size will be proportionally derived from [scale].
  static PreviewLayerBuilder aspectFocus({
    final double scale = 0.5,
    final Color color = Colors.black38,
  }) =>
      (final BuildContext context, PreviewLayerContext layerContext) =>
          ClipPath(
            clipper: _RectClipper(
              rectBuilder: (size) => Rect.fromCenter(
                center: Offset(size.width / 2, size.height / 2),
                width: size.width * scale,
                height: size.height * scale,
              ),
            ),
            child: Container(
              color: color,
            ),
          );

  /// Generates a layer that focus on a square area.
  ///
  /// The [color] parameter defaults to a transparent black, and the focus
  /// size will be proportionally derived from the [scale] applied to the
  /// shortest side of the preview size.
  static PreviewLayerBuilder squareFocus({
    final double scale = 0.5,
    final Color color = Colors.black38,
  }) =>
      (final BuildContext context, PreviewLayerContext layerContext) =>
          ClipPath(
            clipper: _RectClipper(
              rectBuilder: _squareRectBuilder(scale),
            ),
            child: Container(
              color: color,
            ),
          );

  /// Generates a layer that focus on a circular area.
  ///
  /// The [color] parameter defaults to a transparent black, and the focus
  /// size will be proportionally derived from [size].
  static PreviewLayerBuilder circleFocus({
    final double scale = 0.5,
    final Color color = Colors.black38,
  }) =>
      (final BuildContext context, PreviewLayerContext layerContext) =>
          ClipPath(
            clipper: _RoundRectClipper(
              rectBuilder: _squareRectBuilder(scale),
            ),
            child: Container(
              color: color,
            ),
          );

  /// Generates a layer with a centered [image].
  ///
  /// The image will not scale unless a different [scale] is passed.
  static PreviewLayerBuilder image(
    final Image image, {
    final double scale = 1,
  }) =>
      (final BuildContext context, PreviewLayerContext layerContext) => Center(
            child: Transform.scale(
              scale: scale,
              child: image,
            ),
          );

  /// Generate a grid layer with [color].
  static PreviewLayerBuilder grid({
    Color color = Colors.white30,
  }) =>
      (final BuildContext context, PreviewLayerContext layerContext) =>
          CustomPaint(
            painter: _GridPainter(color: color),
            child: Container(),
          );

  /// Builds the builder for square rects.
  static Rect Function(Size) _squareRectBuilder(final double scale) =>
      (final Size size) => Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.shortestSide * scale,
            height: size.shortestSide * scale,
          );
}

class _RectClipper extends CustomClipper<Path> {
  final Rect Function(Size size) rectBuilder;

  const _RectClipper({
    @required this.rectBuilder,
  });

  @override
  Path getClip(Size size) => Path()
    ..addRect(rectBuilder(size))
    ..addRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    )
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RoundRectClipper extends CustomClipper<Path> {
  final Rect Function(Size size) rectBuilder;

  const _RoundRectClipper({
    @required this.rectBuilder,
  });

  @override
  Path getClip(Size size) => Path()
    ..addOval(rectBuilder(size))
    ..addRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    )
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = color;

    // Draw horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 3 * 2),
      Offset(size.width, size.height / 3 * 2),
      paint,
    );

    // Draw vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 3 * 2, 0),
      Offset(size.width / 3 * 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
