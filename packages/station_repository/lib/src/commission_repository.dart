import 'package:storm_api_client/storm_api_client.dart';

/// {@template commission_repository}
/// Manages commission rates, tiers, and category lookups.
/// {@endtemplate}
class CommissionRepository {
  /// {@macro commission_repository}
  const CommissionRepository({required this._apiClient});

  final StormApiClient _apiClient;

  /// Lists all commission configurations.
  TaskEither<StormFailure, List<Commission>> listCommissions() =>
      _apiClient.listCommissionsTE();

  /// Gets the currently active commission.
  TaskEither<StormFailure, Commission> currentCommission() =>
      _apiClient.currentCommissionTE();

  /// Creates a new commission configuration.
  TaskEither<StormFailure, Commission> createCommission(
    CreateCommissionRequest request,
  ) => _apiClient.createCommissionTE(request);

  /// Lists all commission tiers.
  TaskEither<StormFailure, List<CommissionTier>> listTiers() =>
      _apiClient.listCommissionTiersTE();

  /// Gets the commission tier for a specific [category].
  TaskEither<StormFailure, CommissionTier> tierByCategory(String category) =>
      _apiClient.commissionTierByCategoryTE(category);

  /// Creates a new commission tier.
  TaskEither<StormFailure, CommissionTier> createTier(
    CreateCommissionTierRequest request,
  ) => _apiClient.createCommissionTierTE(request);

  /// Lists all categories.
  TaskEither<StormFailure, List<Category>> listCategories() =>
      _apiClient.listCategoriesTE();

  /// Creates a new category.
  TaskEither<StormFailure, Category> createCategory(
    CreateCategoryRequest request,
  ) => _apiClient.createCategoryTE(request);
}
