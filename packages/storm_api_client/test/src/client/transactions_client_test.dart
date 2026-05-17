import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — transactions', () {
    group('listTransactionsTE', () {
      test('returns list of Transaction on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[transactionJson]));
        final result = await buildFakeClient(dio).listTransactionsTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.id, 't1');
        });
      });
    });

    group('listTransactionsByAgentTE', () {
      test('returns list of Transaction on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[transactionJson]));
        final result = await buildFakeClient(
          dio,
        ).listTransactionsByAgentTE('AGT01').run();
        assertRight(result, (v) => expect(v.first.id, 't1'));
      });
    });

    group('withdrawalTE', () {
      test('returns WithdrawalResponse on success', () async {
        final dio = buildFakeDio(
          okResponse(<String, Object?>{
            'message': 'OK',
            'client_balance': 90.0,
            'agent_balance': 10.0,
          }),
        );
        final result = await buildFakeClient(dio)
            .withdrawalTE(
              const WithdrawalRequest(
                clientCode: 'CLI1',
                withdrawalAmount: 10,
                clientPassword: 'pin',
                agentCode: 'AGT01',
                currencyType: 'USD',
              ),
            )
            .run();
        assertRight(result, (v) {
          expect(v.message, 'OK');
          expect(v.clientBalance, 90.0);
        });
      });
    });
  });
}
