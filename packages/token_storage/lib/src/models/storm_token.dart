/// Lightweight representation of the Storm session token.
///
/// Used for serialization into secure storage.
class StormToken {
  const StormToken({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  factory StormToken.fromJson(Map<String, Object?> json) => StormToken(
    accessToken: json['access_token']! as String,
    refreshToken: json['refresh_token'] as String?,
    expiresAt: json['expires_at'] != null
        ? DateTime.parse(json['expires_at']! as String)
        : null,
  );

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  Map<String, Object?> toJson() => {
    'access_token': accessToken,
    if (refreshToken != null) 'refresh_token': refreshToken,
    if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
  };
}
