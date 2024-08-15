class ServerSettings {
  final bool isDirectDownloadAllowed;

  const ServerSettings({required this.isDirectDownloadAllowed});

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'isDirectDownloadAllowed': bool isDirectDownloadAllowed,
      } =>
        ServerSettings(
          isDirectDownloadAllowed: isDirectDownloadAllowed,
        ),
      _ => throw const FormatException('Failed to load server settings.'),
    };
  }
}
