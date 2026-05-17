import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — metrics', () {
    group('getMetricsTE', () {
      test('returns MetricsResponse on success', () async {
        final dio = buildFakeDio(
          okResponse(<String, Object?>{'requests': 42}),
        );
        final result = await buildFakeClient(dio).getMetricsTE().run();
        assertRight(result, (v) => expect(v.requests, 42));
      });
    });
  });
}
