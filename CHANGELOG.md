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