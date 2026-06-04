import 'package:storm_api_client/storm_api_client.dart';

/// {@template consumption_repository}
/// Manages fuel consumption records and fuel price lookups.
/// {@endtemplate}
class ConsumptionRepository {
  /// {@macro consumption_repository}
  const ConsumptionRepository({required this._apiClient});

  final StormApiClient _apiClient;

  /// Records a fuel consumption event.
  TaskEither<StormFailure, Unit> create({
    required String clientRef,
    required String consumptionType,
    required double quantity,
    required double price,
    required String username,
    required bool isOnline,
  }) => IO(() => DateTime.now().toIso8601String())
      .toTaskEither<StormFailure>()
      .flatMap(
        (date) => _apiClient.createConsumptionTE(
          CreateConsumptionRequest(
            date: date,
            clientRef: clientRef,
            consumptionType: consumptionType,
            quantity: quantity,
            price: price,
            username: username,
            isOnline: isOnline,
          ),
        ),
      );

  /// Lists all consumption records.
  TaskEither<StormFailure, List<Consumption>> listAll() =>
      _apiClient.listConsumptionsTE();

  /// Lists consumption records for a specific client.
  TaskEither<StormFailure, List<Consumption>> listByClient(String clientRef) =>
      _apiClient.listConsumptionsByClientTE(clientRef);

  /// Lists all fuel prices.
  TaskEither<StormFailure, List<FuelPrice>> listPrices() =>
      _apiClient.listPricesTE();

  /// Gets the price for a specific consumption type.
  TaskEither<StormFailure, FuelPrice> priceByType(String consumptionType) =>
      _apiClient.priceByTypeTE(consumptionType);

  /// Creates a new fuel price entry.
  TaskEither<StormFailure, FuelPrice> createPrice(
    CreatePriceRequest request,
  ) => _apiClient.createPriceTE(request);
}
