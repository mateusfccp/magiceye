/// Exception returned when anything wrong happens with MagicEye.
class MagicEyeException implements Exception {
  /// A message describing the error.
  final String message;

  /// The actual source input which caused the error.
  final Object source;

  MagicEyeException({this.message, this.source});
}
