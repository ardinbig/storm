import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — cards', () {
    group('listCardsTE', () {
      test('returns list of NfcCard on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[nfcCardJson]));
        final result = await buildFakeClient(dio).listCardsTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.cardId, 'CARD1');
        });
      });
    });

    group('getCardTE', () {
      test('returns NfcCard on success', () async {
        final dio = buildFakeDio(okResponse(nfcCardJson));
        final result = await buildFakeClient(dio).getCardTE('c1').run();
        assertRight(result, (v) => expect(v.id, 'c1'));
      });
    });

    group('createCardTE', () {
      test('returns NfcCard on success', () async {
        final dio = buildFakeDio(okResponse(nfcCardJson));
        final result = await buildFakeClient(
          dio,
        ).createCardTE(const CreateCardRequest(cardId: 'CARD1')).run();
        assertRight(result, (v) => expect(v.cardId, 'CARD1'));
      });
    });

    group('checkBalanceTE', () {
      test('returns BalanceResponse on success', () async {
        final dio = buildFakeDio(okResponse(balanceResponseJson));
        final result = await buildFakeClient(dio)
            .checkBalanceTE(
              nfcRef: 'NFC1',
              request: const BalanceCheckRequest(password: 'pin'),
            )
            .run();
        assertRight(result, (v) => expect(v.clientCode, 'CLI1'));
      });
    });
  });
}
