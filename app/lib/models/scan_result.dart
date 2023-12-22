class ScanResult {
  final bool success;
  final String message;

  const ScanResult({required this.success, required this.message});

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'success': bool success,
        'message': String message,
      } =>
        ScanResult(
          success: success,
          message: message,
        ),
      _ => throw const FormatException('Failed to load scan result.'),
    };
  }
}
