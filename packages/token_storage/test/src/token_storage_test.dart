import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh/fresh.dart';
import 'package:mocktail/mocktail.dart';
import 'package:token_storage/token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late SecureTokenStorage tokenStorage;

  const token = OAuth2Token(accessToken: 'test-access-token');
  const tokenKey = 'storm_oauth2_token';
  const timestampKey = 'storm_token_timestamp';

  setUp(() {
    storage = MockFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(storage: storage);
  });

  group('SecureTokenStorage', () {
    group('read', () {
      test('returns null when token key is absent', () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => null);
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => DateTime.now().toIso8601String());

        final result = await tokenStorage.read();

        expect(result, isNull);
      });

      test('returns null when timestamp key is absent', () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => '{"access_token":"test-access-token"}');
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => null);

        final result = await tokenStorage.read();

        expect(result, isNull);
      });

      test('returns null when stored timestamp is not parseable', () async {
        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => '{"access_token":"test-access-token"}');
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => 'not-a-date');

        final result = await tokenStorage.read();

        expect(result, isNull);
      });

      test('returns null and deletes token when maxAge is exceeded', () async {
        final expired = DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String();

        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => '{"access_token":"test-access-token"}');
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => expired);
        when(
          () => storage.delete(key: tokenKey),
        ).thenAnswer((_) async {});
        when(
          () => storage.delete(key: timestampKey),
        ).thenAnswer((_) async {});

        final result = await tokenStorage.read();

        expect(result, isNull);
        verify(() => storage.delete(key: tokenKey)).called(1);
        verify(() => storage.delete(key: timestampKey)).called(1);
      });

      test('returns token when stored within maxAge', () async {
        final recent = DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String();

        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => '{"access_token":"test-access-token"}');
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => recent);

        final result = await tokenStorage.read();

        expect(result, isNotNull);
        expect(result!.accessToken, 'test-access-token');
        verifyNever(() => storage.delete(key: any(named: 'key')));
      });

      test('respects custom maxAge duration', () async {
        final tokenStorageShort = SecureTokenStorage(
          storage: storage,
          maxAge: const Duration(minutes: 30),
        );
        final tooOld = DateTime.now()
            .subtract(const Duration(minutes: 31))
            .toIso8601String();

        when(
          () => storage.read(key: tokenKey),
        ).thenAnswer((_) async => '{"access_token":"test-access-token"}');
        when(
          () => storage.read(key: timestampKey),
        ).thenAnswer((_) async => tooOld);
        when(
          () => storage.delete(key: tokenKey),
        ).thenAnswer((_) async {});
        when(
          () => storage.delete(key: timestampKey),
        ).thenAnswer((_) async {});

        final result = await tokenStorageShort.read();

        expect(result, isNull);
        verify(() => storage.delete(key: tokenKey)).called(1);
      });
    });

    group('write', () {
      test('persists access token and timestamp', () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await tokenStorage.write(token);

        final captured = verify(
          () => storage.write(
            key: captureAny(named: 'key'),
            value: captureAny(named: 'value'),
          ),
        ).captured;

        expect(captured, hasLength(4));
        expect(captured[0], tokenKey);
        expect(captured[1], contains('test-access-token'));
        expect(captured[2], timestampKey);
        expect(DateTime.tryParse(captured[3] as String), isNotNull);
      });
    });

    group('delete', () {
      test('removes token and timestamp from storage', () async {
        when(
          () => storage.delete(key: tokenKey),
        ).thenAnswer((_) async {});
        when(
          () => storage.delete(key: timestampKey),
        ).thenAnswer((_) async {});

        await tokenStorage.delete();

        verify(() => storage.delete(key: tokenKey)).called(1);
        verify(() => storage.delete(key: timestampKey)).called(1);
      });
    });
  });
}
