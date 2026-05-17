import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — prices', () {
    group('listPricesTE', () {
      test('returns list of FuelPrice on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[fuelPriceJson]));
        final result = await buildFakeClient(dio).listPricesTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.consumptionType, 'diesel');
        });
      });
    });

    group('priceByTypeTE', () {
      test('returns FuelPrice on success', () async {
        final dio = buildFakeDio(okResponse(fuelPriceJson));
        final result = await buildFakeClient(dio).priceByTypeTE('diesel').run();
        assertRight(result, (v) => expect(v.price, 2.0));
      });
    });

    group('createPriceTE', () {
      test('returns FuelPrice on success', () async {
        final dio = buildFakeDio(okResponse(fuelPriceJson));
        final result = await buildFakeClient(dio)
            .createPriceTE(
              const CreatePriceRequest(consumptionType: 'diesel', price: 2),
            )
            .run();
        assertRight(result, (v) => expect(v.id, 'p1'));
      });
    });
  });
}
