import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template storm_api_client}
/// Dio-based HTTP client for the Storm REST API.
///
/// Token management is handled by a [Fresh] interceptor - callers never
/// set tokens manually.
///
/// Every endpoint is exposed through a `*TE()` method returning
/// [TaskEither]`<`[StormFailure]`, T>` - the canonical functional interface
/// consumed by repositories.
/// {@endtemplate}
class StormApiClient {
  /// {@macro storm_api_client}
  StormApiClient({
    required String baseUrl,
    required Fresh<OAuth2Token> freshInterceptor,
    Dio? dio,
  }) : _fresh = freshInterceptor,
       _dio = (dio ?? Dio(BaseOptions(baseUrl: baseUrl)))
         ..interceptors.add(freshInterceptor);

  final Dio _dio;
  final Fresh<OAuth2Token> _fresh;

  /// Exposes the [Fresh] interceptor for the repository layer to listen
  /// to [AuthenticationStatus] changes or set tokens after login.
  Fresh<OAuth2Token> get fresh => _fresh;

  /// Maps any caught error into a [StormFailure].
  ///
  /// [DioException]s are classified by their type and response body.
  StormFailure _mapDioToFailure(Object error, StackTrace _) {
    if (error is! DioException) {
      return StormNetworkFailure(error.toString());
    }
    final e = error;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return StormNetworkFailure(e.message ?? 'Network error');
    }
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map<String, Object?>) {
        try {
          final errorResponse = ErrorResponse.fromJson(body);
          return StormApiFailure(errorResponse.error, errorResponse.code);
        } on Object {
          // Body shape does not match ErrorResponse - fall through.
        }
      }
      return StormApiFailure(
        response.statusMessage ?? 'Unknown error',
        response.statusCode ?? 0,
      );
    }
    return StormNetworkFailure(e.message ?? 'Unknown network error');
  }

  // TaskEither HTTP primitives.

  TaskEither<StormFailure, T> _get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) => TaskEither.tryCatch(
    () async {
      final res = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      return res.data as T;
    },
    _mapDioToFailure,
  );

  TaskEither<StormFailure, T> _post<T>(String path, {Object? data}) =>
      TaskEither.tryCatch(
        () async {
          final res = await _dio.post<Object?>(path, data: data);
          return res.data as T;
        },
        _mapDioToFailure,
      );

  TaskEither<StormFailure, Unit> _postVoid(String path, {Object? data}) =>
      TaskEither.tryCatch(
        () async {
          await _dio.post<void>(path, data: data);
          return unit;
        },
        _mapDioToFailure,
      );

  TaskEither<StormFailure, T> _patch<T>(String path, {Object? data}) =>
      TaskEither.tryCatch(
        () async {
          final res = await _dio.patch<Object?>(path, data: data);
          return res.data as T;
        },
        _mapDioToFailure,
      );

  TaskEither<StormFailure, T> _put<T>(String path, {Object? data}) =>
      TaskEither.tryCatch(
        () async {
          final res = await _dio.put<Object?>(path, data: data);
          return res.data as T;
        },
        _mapDioToFailure,
      );

  TaskEither<StormFailure, Unit> _putVoid(String path, {Object? data}) =>
      TaskEither.tryCatch(
        () async {
          await _dio.put<void>(path, data: data);
          return unit;
        },
        _mapDioToFailure,
      );

  TaskEither<StormFailure, Unit> _deleteVoid(String path) =>
      TaskEither.tryCatch(
        () async {
          await _dio.delete<void>(path);
          return unit;
        },
        _mapDioToFailure,
      );

  // Auth

  /// `POST /api/v1/auth/login`.
  TaskEither<StormFailure, AuthResponse> systemLoginTE(
    LoginRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.authLogin,
    data: request.toJson(),
  ).map(AuthResponse.fromJson);

  /// `POST /api/v1/auth/register`.
  TaskEither<StormFailure, UserInfo> registerTE(RegisterRequest request) =>
      _post<Map<String, Object?>>(
        ApiPaths.authRegister,
        data: request.toJson(),
      ).map(UserInfo.fromJson);

  /// `POST /api/v1/auth/logout`.
  TaskEither<StormFailure, Unit> logoutTE() => _postVoid(ApiPaths.authLogout);

  // Agent Auth

  /// `POST /api/v1/agents/login`.
  TaskEither<StormFailure, AgentAuthResponse> agentLoginTE(
    AgentLoginRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.agentsLogin,
    data: request.toJson(),
  ).map(AgentAuthResponse.fromJson);

  // Users

  /// `GET /api/v1/users/me`.
  TaskEither<StormFailure, MeResponse> meTE() =>
      _get<Map<String, Object?>>(ApiPaths.usersMe).map(MeResponse.fromJson);

  // Activity

  /// `GET /api/v1/activity`.
  TaskEither<StormFailure, PaginatedActivityResponse> listActivityTE({
    int? page,
    String? kind,
    String? agent,
    String? station,
  }) {
    final query = <String, Object?>{
      'page': page,
      'kind': kind,
      'agent': agent,
      'station': station,
    }..removeWhere((_, v) => v == null);
    return _get<Map<String, Object?>>(
      ApiPaths.activity,
      queryParameters: query.isEmpty ? null : query,
    ).map(PaginatedActivityResponse.fromJson);
  }

  // Agents

  /// `GET /api/v1/agents`.
  TaskEither<StormFailure, List<AgentInfo>> listAgentsTE() =>
      _get<List<Object?>>(ApiPaths.agents).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(AgentInfo.fromJson).toList(),
      );

  /// `GET /api/v1/agents/{id}`.
  TaskEither<StormFailure, AgentInfo> getAgentTE(String id) =>
      _get<Map<String, Object?>>(ApiPaths.agent(id)).map(AgentInfo.fromJson);

  /// `POST /api/v1/agents`.
  TaskEither<StormFailure, AgentInfo> createAgentTE(
    CreateAgentRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.agents,
    data: request.toJson(),
  ).map(AgentInfo.fromJson);

  /// `DELETE /api/v1/agents/{id}`.
  TaskEither<StormFailure, Unit> deleteAgentTE(String id) =>
      _deleteVoid(ApiPaths.agent(id));

  /// `PATCH /api/v1/agents/{id}`.
  TaskEither<StormFailure, AgentInfo> updateAgentTE(
    String id,
    UpdateAgentRequest request,
  ) => _patch<Map<String, Object?>>(
    ApiPaths.agent(id),
    data: request.toJson(),
  ).map(AgentInfo.fromJson);

  /// `PUT /api/v1/agents/password`.
  TaskEither<StormFailure, Unit> updateAgentPasswordTE(
    UpdateAgentPasswordRequest request,
  ) => _putVoid(ApiPaths.agentsPassword, data: request.toJson());

  /// `GET /api/v1/agents/{agent_id}/history`.
  TaskEither<StormFailure, List<AgentHistoryRow>> agentHistoryTE(
    String agentId,
  ) => _get<List<Object?>>(ApiPaths.agentHistory(agentId)).map(
    (data) => data
        .cast<Map<String, Object?>>()
        .map(AgentHistoryRow.fromJson)
        .toList(),
  );

  /// `POST /api/v1/cards/{nfc_ref}/balance` (agent variant).
  TaskEither<StormFailure, BalanceResponse> agentCheckBalanceTE(
    String cardId, {
    required BalanceCheckRequest request,
  }) => _post<Map<String, Object?>>(
    ApiPaths.cardBalance(cardId),
    data: request.toJson(),
  ).map(BalanceResponse.fromJson);

  /// `POST /api/v1/agents/customers`.
  TaskEither<StormFailure, Unit> agentRegisterCustomerTE(
    AgentRegisterCustomerRequest request,
  ) => _postVoid(ApiPaths.agentsCustomers, data: request.toJson());

  // Cards

  /// `GET /api/v1/cards`.
  TaskEither<StormFailure, List<NfcCard>> listCardsTE() =>
      _get<List<Object?>>(ApiPaths.cards).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(NfcCard.fromJson).toList(),
      );

  /// `GET /api/v1/cards/{id}`.
  TaskEither<StormFailure, NfcCard> getCardTE(String id) =>
      _get<Map<String, Object?>>(ApiPaths.card(id)).map(NfcCard.fromJson);

  /// `POST /api/v1/cards`.
  TaskEither<StormFailure, NfcCard> createCardTE(
    CreateCardRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.cards,
    data: request.toJson(),
  ).map(NfcCard.fromJson);

  /// `POST /api/v1/cards/{nfc_ref}/balance` (customer variant).
  TaskEither<StormFailure, BalanceResponse> checkBalanceTE({
    required String nfcRef,
    required BalanceCheckRequest request,
  }) => _post<Map<String, Object?>>(
    ApiPaths.cardBalance(nfcRef),
    data: request.toJson(),
  ).map(BalanceResponse.fromJson);

  // Customers

  /// `GET /api/v1/customers`.
  TaskEither<StormFailure, List<Customer>> listCustomersTE() =>
      _get<List<Object?>>(ApiPaths.customers).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(Customer.fromJson).toList(),
      );

  /// `GET /api/v1/customers/{id}`.
  TaskEither<StormFailure, Customer> getCustomerTE(String id) =>
      _get<Map<String, Object?>>(ApiPaths.customer(id)).map(
        Customer.fromJson,
      );

  /// `GET /api/v1/customers/by-card/{card_id}`.
  TaskEither<StormFailure, CustomerByCardResponse> getCustomerByCardTE(
    String cardId,
  ) => _get<Map<String, Object?>>(
    ApiPaths.customerByCard(cardId),
  ).map(CustomerByCardResponse.fromJson);

  /// `POST /api/v1/customers`.
  TaskEither<StormFailure, Customer> registerCustomerTE(
    RegisterCustomerRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.customers,
    data: request.toJson(),
  ).map(Customer.fromJson);

  /// `PUT /api/v1/customers/{id}`.
  TaskEither<StormFailure, Customer> updateCustomerTE(
    String id,
    UpdateCustomerRequest request,
  ) => _put<Map<String, Object?>>(
    ApiPaths.customer(id),
    data: request.toJson(),
  ).map(Customer.fromJson);

  /// `DELETE /api/v1/customers/{id}`.
  TaskEither<StormFailure, Unit> deleteCustomerTE(String id) =>
      _deleteVoid(ApiPaths.customer(id));

  // Transactions

  /// `GET /api/v1/transactions`.
  TaskEither<StormFailure, List<Transaction>> listTransactionsTE() =>
      _get<List<Object?>>(ApiPaths.transactions).map(
        (data) => data
            .cast<Map<String, Object?>>()
            .map(Transaction.fromJson)
            .toList(),
      );

  /// `GET /api/v1/transactions/by-agent/{agent_ref}`.
  TaskEither<StormFailure, List<Transaction>> listTransactionsByAgentTE(
    String agentRef,
  ) =>
      _get<List<Object?>>(
        ApiPaths.transactionsByAgent(agentRef),
      ).map(
        (data) => data
            .cast<Map<String, Object?>>()
            .map(Transaction.fromJson)
            .toList(),
      );

  /// `POST /api/v1/transactions/withdrawal`.
  TaskEither<StormFailure, WithdrawalResponse> withdrawalTE(
    WithdrawalRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.transactionsWithdrawal,
    data: request.toJson(),
  ).map(WithdrawalResponse.fromJson);

  // Consumptions

  /// `GET /api/v1/consumptions`.
  TaskEither<StormFailure, List<Consumption>> listConsumptionsTE() =>
      _get<List<Object?>>(ApiPaths.consumptions).map(
        (data) => data
            .cast<Map<String, Object?>>()
            .map(Consumption.fromJson)
            .toList(),
      );

  /// `GET /api/v1/consumptions/by-client/{client_ref}`.
  TaskEither<StormFailure, List<Consumption>> listConsumptionsByClientTE(
    String clientRef,
  ) =>
      _get<List<Object?>>(
        ApiPaths.consumptionsByClient(clientRef),
      ).map(
        (data) => data
            .cast<Map<String, Object?>>()
            .map(Consumption.fromJson)
            .toList(),
      );

  /// `POST /api/v1/consumptions`.
  TaskEither<StormFailure, Unit> createConsumptionTE(
    CreateConsumptionRequest request,
  ) => _postVoid(ApiPaths.consumptions, data: request.toJson());

  // Commissions

  /// `GET /api/v1/commissions`.
  TaskEither<StormFailure, List<Commission>> listCommissionsTE() =>
      _get<List<Object?>>(ApiPaths.commissions).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(Commission.fromJson).toList(),
      );

  /// `GET /api/v1/commissions/current`.
  TaskEither<StormFailure, Commission> currentCommissionTE() =>
      _get<Map<String, Object?>>(
        ApiPaths.commissionsCurrent,
      ).map(Commission.fromJson);

  /// `POST /api/v1/commissions`.
  TaskEither<StormFailure, Commission> createCommissionTE(
    CreateCommissionRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.commissions,
    data: request.toJson(),
  ).map(Commission.fromJson);

  /// `DELETE /api/v1/commissions/{id}`.
  TaskEither<StormFailure, Unit> deleteCommissionTE(String id) =>
      _deleteVoid(ApiPaths.commission(id));

  // Commission Tiers

  /// `GET /api/v1/commission-tiers`.
  TaskEither<StormFailure, List<CommissionTier>> listCommissionTiersTE() =>
      _get<List<Object?>>(ApiPaths.commissionTiers).map(
        (data) => data
            .cast<Map<String, Object?>>()
            .map(CommissionTier.fromJson)
            .toList(),
      );

  /// `GET /api/v1/commission-tiers/by-category/{category}`.
  TaskEither<StormFailure, CommissionTier> commissionTierByCategoryTE(
    String category,
  ) => _get<Map<String, Object?>>(
    ApiPaths.commissionTierByCategory(category),
  ).map(CommissionTier.fromJson);

  /// `POST /api/v1/commission-tiers`.
  TaskEither<StormFailure, CommissionTier> createCommissionTierTE(
    CreateCommissionTierRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.commissionTiers,
    data: request.toJson(),
  ).map(CommissionTier.fromJson);

  // Prices

  /// `GET /api/v1/prices`.
  TaskEither<StormFailure, List<FuelPrice>> listPricesTE() =>
      _get<List<Object?>>(ApiPaths.prices).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(FuelPrice.fromJson).toList(),
      );

  /// `GET /api/v1/prices/by-type/{consumption_type}`.
  TaskEither<StormFailure, FuelPrice> priceByTypeTE(String consumptionType) =>
      _get<Map<String, Object?>>(
        ApiPaths.priceByType(consumptionType),
      ).map(FuelPrice.fromJson);

  /// `POST /api/v1/prices`.
  TaskEither<StormFailure, FuelPrice> createPriceTE(
    CreatePriceRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.prices,
    data: request.toJson(),
  ).map(FuelPrice.fromJson);

  // Categories

  /// `GET /api/v1/categories`.
  TaskEither<StormFailure, List<Category>> listCategoriesTE() =>
      _get<List<Object?>>(ApiPaths.categories).map(
        (data) =>
            data.cast<Map<String, Object?>>().map(Category.fromJson).toList(),
      );

  /// `GET /api/v1/categories/{id}`.
  TaskEither<StormFailure, Category> getCategoryTE(String id) =>
      _get<Map<String, Object?>>(ApiPaths.category(id)).map(
        Category.fromJson,
      );

  /// `POST /api/v1/categories`.
  TaskEither<StormFailure, Category> createCategoryTE(
    CreateCategoryRequest request,
  ) => _post<Map<String, Object?>>(
    ApiPaths.categories,
    data: request.toJson(),
  ).map(Category.fromJson);

  // Metrics

  /// `GET /api/v1/metrics`.
  TaskEither<StormFailure, MetricsResponse> getMetricsTE() =>
      _get<Map<String, Object?>>(
        ApiPaths.metrics,
      ).map(MetricsResponse.fromJson);
}
