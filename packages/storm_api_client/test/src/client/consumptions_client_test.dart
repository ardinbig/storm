import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — consumptions', () {
    group('listConsumptionsTE', () {
      test('returns list of Consumption on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[consumptionJson]));
        final result = await buildFakeClient(dio).listConsumptionsTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.consumptionType, 'diesel');
        });
      });
    });

    group('listConsumptionsByClientTE', () {
      test('returns list of Consumption on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[consumptionJson]));
        final result = await buildFakeClient(
          dio,
        ).listConsumptionsByClientTE('CLI1').run();
        assertRight(result, (v) => expect(v.first.clientRef, 'CLI1'));
      });
    });

    group('createConsumptionTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio)
            .createConsumptionTE(
              const CreateConsumptionRequest(
                date: '2024-01-01',
                clientRef: 'CLI1',
                consumptionType: 'diesel',
                quantity: 5,
                price: 2,
                username: 'user',
                isOnline: true,
              ),
            )
            .run();
        assertRight(result, (v) => expect(v, unit));
      });
    });
  });
}
