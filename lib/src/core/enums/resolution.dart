/// Affect the quality of the captured image.
///
/// If a preset is not available on the camera being used a preset of lower quality will be selected automatically.
enum Resolution {
  /// 352x288 on iOS, 240p (320x240) on Android
  Low,

  /// 480p (640x480 on iOS, 720x480 on Android)
  Medium,

  /// 720p (1280x720)
  High,

  /// 1080p (1920x1080)
  VeryHigh,

  /// 2160p (3840x2160)
  UltraHigh,

  /// The highest resolution available.
  Max,
}
