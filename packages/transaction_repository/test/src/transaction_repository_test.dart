import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';
import 'package:transaction_repository/transaction_repository.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

/// Builds a [WithdrawalRequest] with an optional [password] override.
WithdrawalRequest _req({String password = '1234'}) => WithdrawalRequest(
  clientCode: 'CL-001',
  withdrawalAmount: 500,
  clientPassword: password,
  agentCode: 'AGT-001',
  currencyType: 'CDF',
);

void main() {
  late MockStormApiClient apiClient;
  late TransactionRepository repository;

  final transaction = Transaction(
    id: 'tx-1',
    agentAccount: 'AGT-001',
    clientAccount: 'CL-001',
    amount: 500,
    commission: 25,
    currencyCode: 'CDF',
    transactionType: 'WITHDRAWAL',
    date: DateTime(2026),
  );

  const withdrawalResponse = WithdrawalResponse(
    message: 'Withdrawal completed',
    clientBalance: 1500,
    agentBalance: 300,
  );

  setUp(() {
    apiClient = MockStormApiClient();
    repository = TransactionRepository(apiClient: apiClient);
  });

  group('TransactionRepository', () {
    group('withdraw', () {
      test('maps request and returns withdrawal result', () async {
        when(() => apiClient.withdrawalTE(_req())).thenReturn(
          TaskEither.right(withdrawalResponse),
        );

        final result = await repository
            .withdraw(
              clientCode: 'CL-001',
              amount: 500,
              clientPassword: '1234',
              agentCode: 'AGT-001',
              currencyType: 'CDF',
            )
            .run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (wr) {
            expect(wr.message, 'Withdrawal completed');
            expect(wr.clientBalance, 1500);
            expect(wr.agentBalance, 300);
          },
        );
        verify(() => apiClient.withdrawalTE(_req())).called(1);
      });

      for (final entry in {
        'StormApiFailure': (
          password: 'bad',
          failure:
              const StormApiFailure('Invalid credentials', 401) as StormFailure,
          check: (StormFailure f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Invalid credentials');
          },
        ),
        'StormNetworkFailure': (
          password: '1234',
          failure: const StormNetworkFailure('No internet') as StormFailure,
          check: (StormFailure f) {
            expect(f, isA<StormNetworkFailure>());
            expect(f.message, 'No internet');
          },
        ),
      }.entries) {
        test('returns ${entry.key} on failure', () async {
          final req = _req(password: entry.value.password);
          when(() => apiClient.withdrawalTE(req)).thenReturn(
            TaskEither.left(entry.value.failure),
          );

          final result = await repository
              .withdraw(
                clientCode: 'CL-001',
                amount: 500,
                clientPassword: entry.value.password,
                agentCode: 'AGT-001',
                currencyType: 'CDF',
              )
              .run();

          result.fold(
            entry.value.check,
            (_) => fail('expected Left but got Right'),
          );
          verify(() => apiClient.withdrawalTE(req)).called(1);
        });
      }
    });

    group('transactionsForAgent', () {
      void stubAgent(TaskEither<StormFailure, List<Transaction>> result) =>
          when(
            () => apiClient.listTransactionsByAgentTE('AGT-001'),
          ).thenReturn(result);

      test('returns transactions for requested agent', () async {
        stubAgent(TaskEither.right([transaction]));

        final result = await repository.transactionsForAgent('AGT-001').run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (list) => expect(list, [transaction]),
        );
        verify(
          () => apiClient.listTransactionsByAgentTE('AGT-001'),
        ).called(1);
      });

      test('returns empty list when agent has no transactions', () async {
        stubAgent(TaskEither.right([]));

        final result = await repository.transactionsForAgent('AGT-001').run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (list) => expect(list, isEmpty),
        );
        verify(
          () => apiClient.listTransactionsByAgentTE('AGT-001'),
        ).called(1);
      });

      test('returns StormApiFailure on error', () async {
        stubAgent(
          TaskEither.left(const StormApiFailure('Agent not found', 404)),
        );

        final result = await repository.transactionsForAgent('AGT-001').run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Agent not found');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(
          () => apiClient.listTransactionsByAgentTE('AGT-001'),
        ).called(1);
      });
    });

    group('allTransactions', () {
      void stubAll(TaskEither<StormFailure, List<Transaction>> result) =>
          when(() => apiClient.listTransactionsTE()).thenReturn(result);

      test('returns all transactions', () async {
        stubAll(TaskEither.right([transaction]));

        final result = await repository.allTransactions().run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (list) => expect(list, [transaction]),
        );
        verify(() => apiClient.listTransactionsTE()).called(1);
      });

      test('returns empty list when there are no transactions', () async {
        stubAll(TaskEither.right([]));

        final result = await repository.allTransactions().run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (list) => expect(list, isEmpty),
        );
        verify(() => apiClient.listTransactionsTE()).called(1);
      });

      test('returns StormNetworkFailure on error', () async {
        stubAll(
          TaskEither.left(const StormNetworkFailure('Connection refused')),
        );

        final result = await repository.allTransactions().run();

        result.fold(
          (f) {
            expect(f, isA<StormNetworkFailure>());
            expect(f.message, 'Connection refused');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(() => apiClient.listTransactionsTE()).called(1);
      });
    });
  });
}
