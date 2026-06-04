import 'package:storm_api_client/storm_api_client.dart';

/// {@template card_repository}
/// Manages NFC card operations: balance checks, card creation (staging),
/// and card listing.
/// {@endtemplate}
class CardRepository {
  /// {@macro card_repository}
  const CardRepository({required this._apiClient});

  final StormApiClient _apiClient;

  /// Agent-level balance check (PIN/password required by API contract).
  TaskEither<StormFailure, BalanceResponse> agentCheckBalance({
    required String cardId,
    required String password,
  }) => _apiClient.agentCheckBalanceTE(
    cardId,
    request: BalanceCheckRequest(password: password),
  );

  /// Customer-level balance check (PIN required).
  TaskEither<StormFailure, BalanceResponse> customerCheckBalance({
    required String nfcRef,
    required String password,
  }) => _apiClient.checkBalanceTE(
    nfcRef: nfcRef,
    request: BalanceCheckRequest(password: password),
  );

  /// Creates a new staging NFC card (admin feature).
  TaskEither<StormFailure, NfcCard> createStagingCard({
    required String cardId,
  }) => _apiClient.createCardTE(CreateCardRequest(cardId: cardId));

  /// Lists all NFC cards.
  TaskEither<StormFailure, List<NfcCard>> listCards() =>
      _apiClient.listCardsTE();

  /// Gets a single card by [id].
  TaskEither<StormFailure, NfcCard> getCard(String id) =>
      _apiClient.getCardTE(id);
}
