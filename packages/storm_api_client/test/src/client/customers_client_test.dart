import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — customers', () {
    group('listCustomersTE', () {
      test('returns list of Customer on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[customerJson]));
        final result = await buildFakeClient(dio).listCustomersTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.cardId, 'CARD1');
        });
      });
    });

    group('getCustomerTE', () {
      test('returns Customer on success', () async {
        final dio = buildFakeDio(okResponse(customerJson));
        final result = await buildFakeClient(dio).getCustomerTE('cu1').run();
        assertRight(result, (v) => expect(v.id, 'cu1'));
      });
    });

    group('getCustomerByCardTE', () {
      test('returns CustomerByCardResponse on success', () async {
        final dio = buildFakeDio(
          okResponse(<String, Object?>{'client_code': 'CLI1'}),
        );
        final result = await buildFakeClient(
          dio,
        ).getCustomerByCardTE('CARD1').run();
        assertRight(result, (v) => expect(v.clientCode, 'CLI1'));
      });
    });

    group('registerCustomerTE', () {
      test('returns Customer on success', () async {
        final dio = buildFakeDio(okResponse(customerJson));
        final result = await buildFakeClient(dio)
            .registerCustomerTE(
              const RegisterCustomerRequest(
                cardId: 'CARD1',
                firstName: 'John',
                lastName: 'Doe',
                phone: '0600000001',
              ),
            )
            .run();
        assertRight(result, (v) => expect(v.status, 1));
      });
    });

    group('updateCustomerTE', () {
      test('returns updated Customer on success', () async {
        final dio = buildFakeDio(
          okResponse({...customerJson, 'first_name': 'Jane'}),
        );
        final result = await buildFakeClient(dio)
            .updateCustomerTE(
              'cu1',
              const UpdateCustomerRequest(firstName: 'Jane'),
            )
            .run();
        assertRight(result, (v) => expect(v.firstName, 'Jane'));
      });
    });

    group('deleteCustomerTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio).deleteCustomerTE('cu1').run();
        assertRight(result, (v) => expect(v, unit));
      });
    });
  });
}
