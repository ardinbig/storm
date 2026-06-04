import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — commissions', () {
    group('listCommissionsTE', () {
      test('returns list of Commission on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[commissionJson]));
        final result = await buildFakeClient(dio).listCommissionsTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.percentage, 5.0);
        });
      });
    });

    group('currentCommissionTE', () {
      test('returns current Commission on success', () async {
        final dio = buildFakeDio(okResponse(commissionJson));
        final result = await buildFakeClient(dio).currentCommissionTE().run();
        assertRight(result, (v) => expect(v.id, 'com1'));
      });
    });

    group('createCommissionTE', () {
      test('returns Commission on success', () async {
        final dio = buildFakeDio(okResponse(commissionJson));
        final result = await buildFakeClient(dio)
            .createCommissionTE(const CreateCommissionRequest(percentage: 5))
            .run();
        assertRight(result, (v) => expect(v.percentage, 5.0));
      });
    });

    group('deleteCommissionTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(
          dio,
        ).deleteCommissionTE('com1').run();
        assertRight(result, (v) => expect(v, unit));
      });
    });
  });

  group('StormApiClient — commission tiers', () {
    group('listCommissionTiersTE', () {
      test('returns list of CommissionTier on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[commissionTierJson]));
        final result = await buildFakeClient(dio).listCommissionTiersTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.level1, 0.1);
        });
      });
    });

    group('commissionTierByCategoryTE', () {
      test('returns CommissionTier on success', () async {
        final dio = buildFakeDio(okResponse(commissionTierJson));
        final result = await buildFakeClient(
          dio,
        ).commissionTierByCategoryTE('gold').run();
        assertRight(result, (v) => expect(v.id, 'tier1'));
      });
    });

    group('createCommissionTierTE', () {
      test('returns CommissionTier on success', () async {
        final dio = buildFakeDio(okResponse(commissionTierJson));
        final result = await buildFakeClient(dio)
            .createCommissionTierTE(
              const CreateCommissionTierRequest(level1: 0.1, level2: 0.2),
            )
            .run();
        assertRight(result, (v) => expect(v.level2, 0.2));
      });
    });
  });
}
