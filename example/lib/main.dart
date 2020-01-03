import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magiceye/magiceye.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: LoucoButton(),
        ),
      ),
    );
  }
}

class LoucoButton extends StatelessWidget {
  final StreamController<File> file = StreamController.broadcast();

  LoucoButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        child: Column(
          children: <Widget>[
            Text("Take picture"),
            SizedBox(height: 16),
            StreamBuilder<File>(
              stream: file.stream,
              initialData: null,
              builder: (context, snapshot) =>
                  snapshot.hasData ? Image.file(snapshot.data) : Container(),
            ),
          ],
        ),
        onPressed: () => MagicEye(
          allowedDirections: const {DeviceDirection.landscape},
          previewLayer: _t,
        ).push(context).then(
          (path) {
            file.add(
              File(path),
            );
          },
        ),
      ),
    );
  }
}

Widget _t(BuildContext context, PreviewLayerContext layerContext) {
  List<int> orientations = [0, 0];

  return StreamBuilder<DeviceDirection>(
    initialData: DeviceDirection.portrait,
    stream: layerContext.direction,
    builder: (context, snapshot) {
      final bool enabled =
          layerContext.allowedDirections.contains(snapshot.data);
      orientations = [orientations[0], toDegrees(snapshot.data)];

      final Color red = const Color(0xB4EC3838);

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: enabled
            ? Container(
                width: double.infinity,
                height: double.infinity,
                key: Key("enabled"),
                child: SvgPicture.asset(
                  'assets/odometer.svg',
                  color: Colors.white54,
                ),
              )
            : Container(
                key: Key("disabled"),
                alignment: Alignment.center,
                child: TweenAnimationBuilder(
                  curve: Curves.easeOut,
                  duration: Duration(milliseconds: 300),
                  tween: IntTween(begin: orientations[0], end: orientations[1]),
                  builder: (context, rotation, child) => Transform.rotate(
                    angle: rotation * pi / 180,
                    child: child,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(12),
                        child: const Icon(
                          Icons.screen_rotation,
                          color: Colors.white,
                          size: 32,
                        ),
                        decoration: BoxDecoration(
                          color: red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        color: red,
                        child: Text(
                          "Orientação do celular incorreta. Gire o celular!",
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    },
  );
}
