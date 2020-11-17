# 0.1.7+1

* My linter was broken, so I uploaded last version with a lot of errors. :(
* This version is just those errors fixed

## 0.1.7

* Correctly export `ResolutionPreset` and `CameraLensDirection` enums
* Updated pubspec.yaml flutter.plugin
* Defined minimal flutter version to 1.12 on pubspec.yaml

## 0.1.6+1

* Update pubspec.yaml

## 0.1.6

* Upgrade `dartz` to `^0.9.0`
* In this new version, we can now use `const None()` instead of simply `None()`, so I replaced all instances 🙃

## 0.1.5

* Upgrade `rxdart` to `^0.24.0`
* Apply `pedantic` rules (for some reason, I forgot to include the package on 0.1.3+2, so my linter wouldn't behave correctly)
* Remove `pubspec.lock` from git, as it is recommended for library packages.[¹](https://dart.dev/guides/libraries/private-files#pubspeclock) 

## 0.1.4

* Added a new parameter to `MagicEye` to control preview alignment.
* **Possibly Breaking Change:** By default, the alignment is now `topCenter`.

## 0.1.3+2

* Added a [`analysis_options.yaml`](https://dart.dev/guides/language/analysis-options) file
  * Included [`pedantic`](https://github.com/dart-lang/pedantic) linter rules
  * Set up stricter rules for static anasysis

## 0.1.3+1

* Fix regression (issue #3)

## 0.1.3

* Fix defaultCameraControlLayer secondChild getting the firstChild hit

## 0.1.2

* Assert that `MagicEye` parameters are not `null`, except for `key`
* Export default layers
* Constrained example orientation with `SystemChrome.setPreferredOrientations`

## 0.1.1

* Now the default allowed directions is not `portrait`, but all of them, as it's more intuitive
* Little improvement on in-code documentation
* **Possibly Breaking Change:** Change DeviceDirection enum to represent more intuitively the directions. Now, `landscape` is `landscapeLeft`, and `landscapeReversed` is  `landscapeRight`

## 0.1.0+3

* Updated README.md
* Formatting

## 0.1.0+2

* Updated README.md

## 0.1.0+1

* Updated README.md

## 0.1.0

* API has reached a reasonable stability
* README.md has been updated with enough info
* Little update on the documentation

## 0.0.15+4

* Fix [BehaviorSubject] instantiation

## 0.0.15

* Little improvement on NaviveDeviceDirection handling

## 0.0.14+4

* Fix for [DeviceDirection.difference]
* Tests for [DeviceDirection.difference]

## 0.0.14+1

* Adjustment on [DeviceDirection.difference] method

## 0.0.14

* Added a method to returs the difference of directions in degrees
* See [DeviceDirection.difference]

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

* This breaks the API
* Instead of returning an [Option<String>], the [.push] method now returns a [Either<MagicEyeException, String>], in concordance with [takePicture] method. This change provides an efficient way to handle camera exceptions
* Improvements on documentation

## 0.0.8

* Make functions [toRadian] and [toDegrees] for [DeviceDirection] into extension methods ([.radian] and [.degrees] respectively)
* For this, raised Dart SDK requirement to 2.7
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

* Instead of [pushWithConfirmation] (not yet implemented), the confirmation screen has been implemented on the [defaultCameraControlLayer] method
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

The readme will be made later. Thanks

The example folder is working, but its just a personal test of the package. A proper example with MREs and diverse
options will be available in the future