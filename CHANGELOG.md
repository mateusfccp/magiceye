## 0.1.0

* API has reached a reasonable stability.
* README.md has been updated with enough info.
* Little update on the documentation.

## 0.0.15+4

* Fix [BehaviorSubject] instantiation.

## 0.0.15

* Little improvement on NaviveDeviceDirection handling.

## 0.0.14+4

* Fix for [DeviceDirection.difference].
* Tests for [DeviceDirection.difference].

## 0.0.14+1

* Adjustment on [DeviceDirection.difference] method.

## 0.0.14

* Added a method to returs the difference of directions in degrees.
* See [DeviceDirection.difference].

## 0.0.13+4

* Center image on default control layer confirmation

## 0.0.13+3

* Small update on README.md

## 0.0.13+1

* Deal with all warnings

## 0.0.13

* Dealing with controllers' resources release (issue present since 0.0.1)
* Fixes camera freezing by disconnection (issue present since 0.0.1)
* Small cleanup and documentation update

## 0.0.12

* Fixed error handling

## 0.0.11

* Provide direction as a BehaviorSubject instead of a Stream on contexts
* Improvements on defaultCameraControl
* Example cleanups

## 0.0.10

* Fixed PreviewLayer functions

## 0.0.9+1

* Some corrections on formatting
* Updated description
* Updated rxdart dependency

## 0.0.9

* This breaks the API.
* Instead of returning an [Option<String>], the [.push] method now returns a [Either<MagicEyeException, String>], in concordance with [takePicture] method. This change provides an efficient way to handle camera exceptions.
* Improvements on documentation

## 0.0.8

* Make functions [toRadian] and [toDegrees] for [DeviceDirection] into extension methods ([.radian] and [.degrees] respectively).
* For this, raised Dart SDK requirement to 2.7.
* Also, reraised required path_provider version to 1.5.1

## 0.0.7

* Lowered required path_provider version to 1.5.0 so it's backward compatible with Flutter 1.9

## 0.0.6

* Lowered required rxdart version to ^0.22.5

## 0.0.5

* Lowered required Dart SDK to 2.5

## 0.0.4

* Exported DeviceCamera

## 0.0.3

* Unexported default_camera_control_layer

## 0.0.2

* Instead of [pushWithConfirmation] (not yet implemented), the confirmation screen has been implemented on the [defaultCameraControlLayer] method.
* Change on package structure
* Little change on API: instead of returning a String, now the MagicEye return an [Option<String>]. Futurely, it will return a [Either<MagicEyeException, String>]

## 0.0.1

* Initial release: basic functionality
* Default preview and controls
* Allow for custom control and preview layers

### Known Issues

* Old controllers not being disposed
* Camera goes disabled by policy if the device locked
* Camera freezes if you change to another app that uses the camera
* No proper handle of black area when the device's aspect ratio is higher than camera's one

### Other info

The readme will be made later. Thanks.

The example folder is working, but its just a personal test of the package. A proper example with MREs and diverse
options will be available in the future.