import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:station_repository/station_repository.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

void main() {
  late MockStormApiClient apiClient;
  late CommissionRepository repository;

  final commission = Commission(
    id: 'commission-1',
    percentage: 2.5,
    createdAt: DateTime(2026),
  );

  final tier = CommissionTier(
    id: 'tier-1',
    level1: 1,
    level2: 2,
    category: 'fuel',
    createdAt: DateTime(2026, 1, 2),
  );

  final category = Category(
    id: 'cat-1',
    name: 'fuel',
    createdAt: DateTime(2026, 1, 3),
  );

  setUp(() {
    apiClient = MockStormApiClient();
    repository = CommissionRepository(apiClient: apiClient);
  });

  group('CommissionRepository', () {
    test('listCommissions returns all commissions from api client', () async {
      when(() => apiClient.listCommissionsTE()).thenReturn(
        TaskEither.right([commission]),
      );

      final result = await repository.listCommissions().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [commission]),
      );
      verify(() => apiClient.listCommissionsTE()).called(1);
    });

    test('listCommissions returns StormNetworkFailure on error', () async {
      when(() => apiClient.listCommissionsTE()).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final result = await repository.listCommissions().run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'No internet');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.listCommissionsTE()).called(1);
    });

    test(
      'currentCommission returns current commission from api client',
      () async {
        when(() => apiClient.currentCommissionTE()).thenReturn(
          TaskEither.right(commission),
        );

        final result = await repository.currentCommission().run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (c) => expect(c, commission),
        );
        verify(() => apiClient.currentCommissionTE()).called(1);
      },
    );

    test('currentCommission returns StormApiFailure on error', () async {
      when(() => apiClient.currentCommissionTE()).thenReturn(
        TaskEither.left(const StormApiFailure('Not found', 404)),
      );

      final result = await repository.currentCommission().run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Not found');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.currentCommissionTE()).called(1);
    });

    test(
      'createCommission forwards request and returns created commission',
      () async {
        const request = CreateCommissionRequest(percentage: 3.5);
        when(() => apiClient.createCommissionTE(request)).thenReturn(
          TaskEither.right(commission),
        );

        final result = await repository.createCommission(request).run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (c) => expect(c, commission),
        );
        verify(() => apiClient.createCommissionTE(request)).called(1);
      },
    );

    test(
      'createCommission returns StormApiFailure for invalid percentage',
      () async {
        const request = CreateCommissionRequest(percentage: -1);
        when(() => apiClient.createCommissionTE(request)).thenReturn(
          TaskEither.left(const StormApiFailure('Invalid percentage', 400)),
        );

        final result = await repository.createCommission(request).run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Invalid percentage');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(() => apiClient.createCommissionTE(request)).called(1);
      },
    );

    test('listTiers returns commission tiers from api client', () async {
      when(() => apiClient.listCommissionTiersTE()).thenReturn(
        TaskEither.right([tier]),
      );

      final result = await repository.listTiers().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [tier]),
      );
      verify(() => apiClient.listCommissionTiersTE()).called(1);
    });

    test('listTiers returns empty list when no tiers are configured', () async {
      when(() => apiClient.listCommissionTiersTE()).thenReturn(
        TaskEither.right([]),
      );

      final result = await repository.listTiers().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, isEmpty),
      );
      verify(() => apiClient.listCommissionTiersTE()).called(1);
    });

    test('tierByCategory returns matching tier', () async {
      when(() => apiClient.commissionTierByCategoryTE('fuel')).thenReturn(
        TaskEither.right(tier),
      );

      final result = await repository.tierByCategory('fuel').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (t) => expect(t, tier),
      );
      verify(() => apiClient.commissionTierByCategoryTE('fuel')).called(1);
    });

    test(
      'tierByCategory returns StormApiFailure when category does not exist',
      () async {
        when(() => apiClient.commissionTierByCategoryTE('unknown')).thenReturn(
          TaskEither.left(const StormApiFailure('Category not found', 404)),
        );

        final result = await repository.tierByCategory('unknown').run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Category not found');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(() => apiClient.commissionTierByCategoryTE('unknown')).called(1);
      },
    );

    test('createTier forwards request and returns created tier', () async {
      const request = CreateCommissionTierRequest(
        level1: 1.5,
        level2: 2.5,
        category: 'fuel',
      );
      when(() => apiClient.createCommissionTierTE(request)).thenReturn(
        TaskEither.right(tier),
      );

      final result = await repository.createTier(request).run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (t) => expect(t, tier),
      );
      verify(() => apiClient.createCommissionTierTE(request)).called(1);
    });

    test('createTier returns StormNetworkFailure on error', () async {
      const request = CreateCommissionTierRequest(level1: 1, level2: 2);
      when(() => apiClient.createCommissionTierTE(request)).thenReturn(
        TaskEither.left(const StormNetworkFailure('Connection refused')),
      );

      final result = await repository.createTier(request).run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'Connection refused');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.createCommissionTierTE(request)).called(1);
    });

    test('listCategories returns categories from api client', () async {
      when(() => apiClient.listCategoriesTE()).thenReturn(
        TaskEither.right([category]),
      );

      final result = await repository.listCategories().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [category]),
      );
      verify(() => apiClient.listCategoriesTE()).called(1);
    });

    test(
      'listCategories returns empty list when no categories are configured',
      () async {
        when(() => apiClient.listCategoriesTE()).thenReturn(
          TaskEither.right([]),
        );

        final result = await repository.listCategories().run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (list) => expect(list, isEmpty),
        );
        verify(() => apiClient.listCategoriesTE()).called(1);
      },
    );

    test(
      'createCategory forwards request and returns created category',
      () async {
        const request = CreateCategoryRequest(name: 'transport');
        when(() => apiClient.createCategoryTE(request)).thenReturn(
          TaskEither.right(category),
        );

        final result = await repository.createCategory(request).run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (c) => expect(c, category),
        );
        verify(() => apiClient.createCategoryTE(request)).called(1);
      },
    );

    test(
      'createCategory returns StormApiFailure when category already exists',
      () async {
        const request = CreateCategoryRequest(name: 'fuel');
        when(() => apiClient.createCategoryTE(request)).thenReturn(
          TaskEither.left(
            const StormApiFailure('Category already exists', 409),
          ),
        );

        final result = await repository.createCategory(request).run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Category already exists');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(() => apiClient.createCategoryTE(request)).called(1);
      },
    );
  });
}
