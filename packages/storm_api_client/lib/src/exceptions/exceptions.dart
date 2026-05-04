import 'package:storm_api_client/storm_api_client.dart';

/// Exception thrown when the Storm API returns a non-success response.
class StormApiException implements Exception {
  const StormApiException(this.error, this.statusCode);

  factory StormApiException.fromErrorResponse(
    ErrorResponse response,
  ) => StormApiException(response.error, response.code);

  final String error;
  final int statusCode;

  @override
  String toString() => 'StormApiException($statusCode): $error';
}

/// Exception thrown when there is a network-level failure.
class StormApiNetworkException implements Exception {
  const StormApiNetworkException(this.message);

  final String message;

  @override
  String toString() => 'StormApiNetworkException: $message';
}

/// Sealed failure type for all Storm API operations.
///
/// Use [StormApiFailure] for server-side errors and [StormNetworkFailure]
/// for connectivity-level errors.
sealed class StormFailure {
  const StormFailure(this.message);

  /// Description message of the failure.
  final String message;

  /// Converts to the equivalent [Exception].
  Exception get asException;

  /// Display message for UI snack bars / error states.
  ///
  /// - [StormApiFailure] → The server-provided error message.
  /// - [StormNetworkFailure] → `'Network error. Please retry.'`
  String get toDisplayMessage;
}

/// A server returned a non-success HTTP status.
final class StormApiFailure extends StormFailure {
  const StormApiFailure(super.message, this.statusCode);

  /// The HTTP status code returned by the server.
  final int statusCode;

  @override
  Exception get asException => StormApiException(message, statusCode);

  @override
  String get toDisplayMessage => message;
}

/// A network-level error prevented the request from completing.
final class StormNetworkFailure extends StormFailure {
  const StormNetworkFailure(super.message);

  @override
  Exception get asException => StormApiNetworkException(message);

  @override
  String get toDisplayMessage => 'Network error. Please retry.';
}

/// Maps any caught error to a [StormFailure].
///
/// Use this as the `onError` argument of `TaskEither.tryCatch` in every
/// repository so the mapping logic is defined once and tested in one place.
///
/// - [StormApiException] → [StormApiFailure]
/// - [StormApiNetworkException] → [StormNetworkFailure]
/// - Anything else → [StormNetworkFailure] (treated as an unexpected error)
StormFailure mapStormError(Object error, StackTrace _) {
  if (error is StormApiException) {
    return StormApiFailure(error.error, error.statusCode);
  }
  if (error is StormApiNetworkException) {
    return StormNetworkFailure(error.message);
  }
  return StormNetworkFailure(error.toString());
}
