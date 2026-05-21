/// The authentication status of the application.
enum AuthStatus {
  /// The authentication status is unknown (e.g., app just launched).
  unknown,

  /// The user is authenticated (either as system user or agent).
  authenticated,

  /// The user is not authenticated.
  unauthenticated,
}
