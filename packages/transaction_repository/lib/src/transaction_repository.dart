import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template transaction_repository}
/// Repository for financial transactions and withdrawal operations.
/// {@endtemplate}
class TransactionRepository {
  /// {@macro transaction_repository}
  const TransactionRepository({required StormApiClient apiClient})
    : _apiClient = apiClient;

  final StormApiClient _apiClient;

  /// Performs an atomic withdrawal: deducts from customer card,
  /// credits agent account, applies commission.
  TaskEither<StormFailure, WithdrawalResult> withdraw({
    required String clientCode,
    required double amount,
    required String clientPassword,
    required String agentCode,
    required String currencyType,
  }) => _apiClient
      .withdrawalTE(
        WithdrawalRequest(
          clientCode: clientCode,
          withdrawalAmount: amount,
          clientPassword: clientPassword,
          agentCode: agentCode,
          currencyType: currencyType,
        ),
      )
      .map(
        (response) => WithdrawalResult(
          message: response.message,
          clientBalance: response.clientBalance,
          agentBalance: response.agentBalance,
        ),
      );

  /// Lists all transactions for a specific agent.
  TaskEither<StormFailure, List<Transaction>> transactionsForAgent(
    String agentRef,
  ) => _apiClient.listTransactionsByAgentTE(agentRef);

  /// Lists all transactions (admin).
  TaskEither<StormFailure, List<Transaction>> allTransactions() =>
      _apiClient.listTransactionsTE();
}

/// Domain entity for a completed withdrawal.
class WithdrawalResult {
  const WithdrawalResult({
    required this.message,
    required this.clientBalance,
    required this.agentBalance,
  });

  final String message;
  final double clientBalance;
  final double agentBalance;
}
