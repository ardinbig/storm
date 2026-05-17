import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — categories', () {
    group('listCategoriesTE', () {
      test('returns list of Category on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[categoryJson]));
        final result = await buildFakeClient(dio).listCategoriesTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.name, 'Gold');
        });
      });
    });

    group('getCategoryTE', () {
      test('returns Category on success', () async {
        final dio = buildFakeDio(okResponse(categoryJson));
        final result = await buildFakeClient(dio).getCategoryTE('cat1').run();
        assertRight(result, (v) => expect(v.id, 'cat1'));
      });
    });

    group('createCategoryTE', () {
      test('returns Category on success', () async {
        final dio = buildFakeDio(okResponse(categoryJson));
        final result = await buildFakeClient(
          dio,
        ).createCategoryTE(const CreateCategoryRequest(name: 'Gold')).run();
        assertRight(result, (v) => expect(v.name, 'Gold'));
      });
    });
  });
}
