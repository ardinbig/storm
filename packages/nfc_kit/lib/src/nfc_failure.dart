/// Sealed failure type for NFC session operations.
///
/// Use [NfcUnavailableFailure] when NFC hardware is absent or disabled,
/// [NfcEmptyTagFailure] when a tag is detected but carries no readable ID,
/// and [NfcPollFailure] for any platform-channel or hardware error during
/// polling.
sealed class NfcFailure {
  const NfcFailure(this.message);

  /// Human-readable description of the failure.
  final String message;
}

/// NFC is not available or not enabled on the device.
final class NfcUnavailableFailure extends NfcFailure {
  const NfcUnavailableFailure([super.message = 'NFC is not available.']);
}

/// A tag was detected but its ID was empty or unreadable.
final class NfcEmptyTagFailure extends NfcFailure {
  const NfcEmptyTagFailure([super.message = 'NFC tag ID was empty.']);
}

/// A platform-channel or hardware error occurred during polling.
final class NfcPollFailure extends NfcFailure {
  const NfcPollFailure(super.message);
}
