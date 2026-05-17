import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — activity', () {
    group('listActivityTE', () {
      test('returns PaginatedActivityResponse with no query args', () async {
        final dio = buildFakeDio(okResponse(paginatedActivityJson));
        final result = await buildFakeClient(dio).listActivityTE().run();
        assertRight(result, (v) {
          expect(v.page, 1);
          expect(v.data, isEmpty);
        });
      });

      test('returns PaginatedActivityResponse with all query args', () async {
        final dio = buildFakeDio(okResponse(paginatedActivityJson));
        final result = await buildFakeClient(dio)
            .listActivityTE(
              page: 2,
              kind: 'WITHDRAWAL',
              agent: 'AGT01',
              station: 'ST01',
            )
            .run();
        assertRight(result, (v) => expect(v.page, 1));
      });
    });
  });
}
