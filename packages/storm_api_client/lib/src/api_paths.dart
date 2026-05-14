/// Central registry of every REST path used by `StormApiClient`.
///
/// Fixed (non-parameterised) routes are exposed as `static const` [String]
/// values so that they resolve at compile time and can be used in `const`
/// contexts.
///
/// Parameterised routes are exposed as `static` methods that accept the
/// dynamic path segments as [String] arguments, keeping the interpolation
/// logic in a single, auditable location.
///
/// ## Example
///
/// ```dart
/// // Fixed path — resolved at compile time.
/// final loginPath = ApiPaths.authLogin; // '/api/v1/auth/login'
///
/// // Parameterised path — resolved at call time.
/// final agentPath = ApiPaths.agent('abc-123'); // '/api/v1/agents/abc-123'
/// ```
abstract final class ApiPaths {
  /// The versioned API prefix shared by every endpoint.
  static const String _v1 = '/api/v1';

  // Auth

  /// Path for authenticating a system user.
  ///
  /// `POST /api/v1/auth/login`
  static const String authLogin = '$_v1/auth/login';

  /// Path for registering a new system user.
  ///
  /// `POST /api/v1/auth/register`
  static const String authRegister = '$_v1/auth/register';

  /// Path for logging out the currently authenticated user.
  ///
  /// `POST /api/v1/auth/logout`
  static const String authLogout = '$_v1/auth/logout';

  // Agent Auth

  /// Path for authenticating an agent.
  ///
  /// `POST /api/v1/agents/login`
  static const String agentsLogin = '$_v1/agents/login';

  // Users

  /// Path for retrieving the profile of the currently authenticated user.
  ///
  /// `GET /api/v1/users/me`
  static const String usersMe = '$_v1/users/me';

  // Activity

  /// Path for listing paginated activity records.
  ///
  /// `GET /api/v1/activity`
  static const String activity = '$_v1/activity';

  // Agents

  /// Path for the agents collection (list / create).
  ///
  /// `GET /api/v1/agents` · `POST /api/v1/agents`
  static const String agents = '$_v1/agents';

  /// Path for updating the authenticated agent's password.
  ///
  /// `PUT /api/v1/agents/password`
  static const String agentsPassword = '$_v1/agents/password';

  /// Path for an agent registering a new customer on their behalf.
  ///
  /// `POST /api/v1/agents/customers`
  static const String agentsCustomers = '$_v1/agents/customers';

  /// Returns the path for a single agent identified by [id].
  ///
  /// Used by get, update (`PATCH`), and delete (`DELETE`) operations.
  ///
  /// `GET /api/v1/agents/{id}`
  /// `PATCH /api/v1/agents/{id}`
  /// `DELETE /api/v1/agents/{id}`
  static String agent(String id) => '$_v1/agents/$id';

  /// Returns the activity-history path for the agent identified by [agentId].
  ///
  /// `GET /api/v1/agents/{agentId}/history`
  static String agentHistory(String agentId) => '$_v1/agents/$agentId/history';

  // Cards

  /// Path for the NFC-card collection (list / create).
  ///
  /// `GET /api/v1/cards` · `POST /api/v1/cards`
  static const String cards = '$_v1/cards';

  /// Returns the path for a single NFC card identified by [id].
  ///
  /// `GET /api/v1/cards/{id}`
  static String card(String id) => '$_v1/cards/$id';

  /// Returns the balance-check path for the card identified by [nfcRef].
  ///
  /// Used by both the customer and agent balance-check variants.
  ///
  /// `POST /api/v1/cards/{nfcRef}/balance`
  static String cardBalance(String nfcRef) => '$_v1/cards/$nfcRef/balance';

  // Customers

  /// Path for the customer collection (list / create).
  ///
  /// `GET /api/v1/customers` · `POST /api/v1/customers`
  static const String customers = '$_v1/customers';

  /// Returns the path for a single customer identified by [id].
  ///
  /// Used by get, update (`PUT`), and delete (`DELETE`) operations.
  ///
  /// `GET /api/v1/customers/{id}`
  /// `PUT /api/v1/customers/{id}`
  /// `DELETE /api/v1/customers/{id}`
  static String customer(String id) => '$_v1/customers/$id';

  /// Returns the path for looking up a customer by their associated card.
  ///
  /// `GET /api/v1/customers/by-card/{cardId}`
  static String customerByCard(String cardId) =>
      '$_v1/customers/by-card/$cardId';

  // Transactions

  /// Path for the transaction collection (list all).
  ///
  /// `GET /api/v1/transactions`
  static const String transactions = '$_v1/transactions';

  /// Path for creating a withdrawal transaction.
  ///
  /// `POST /api/v1/transactions/withdrawal`
  static const String transactionsWithdrawal = '$_v1/transactions/withdrawal';

  /// Returns the path for listing transactions that belong to [agentRef].
  ///
  /// `GET /api/v1/transactions/by-agent/{agentRef}`
  static String transactionsByAgent(String agentRef) =>
      '$_v1/transactions/by-agent/$agentRef';

  // Consumptions

  /// Path for the consumption collection (list all / create).
  ///
  /// `GET /api/v1/consumptions` · `POST /api/v1/consumptions`
  static const String consumptions = '$_v1/consumptions';

  /// Returns the path for listing consumptions that belong to [clientRef].
  ///
  /// `GET /api/v1/consumptions/by-client/{clientRef}`
  static String consumptionsByClient(String clientRef) =>
      '$_v1/consumptions/by-client/$clientRef';

  // Commissions

  /// Path for the commission collection (list all / create).
  ///
  /// `GET /api/v1/commissions` · `POST /api/v1/commissions`
  static const String commissions = '$_v1/commissions';

  /// Path for retrieving the currently active commission configuration.
  ///
  /// `GET /api/v1/commissions/current`
  static const String commissionsCurrent = '$_v1/commissions/current';

  /// Returns the path for a single commission identified by [id].
  ///
  /// Used by delete (`DELETE`) operations.
  ///
  /// `DELETE /api/v1/commissions/{id}`
  static String commission(String id) => '$_v1/commissions/$id';

  // Commission Tiers

  /// Path for the commission-tier collection (list all / create).
  ///
  /// `GET /api/v1/commission-tiers` · `POST /api/v1/commission-tiers`
  static const String commissionTiers = '$_v1/commission-tiers';

  /// Returns the path for looking up a commission tier by [category] name.
  ///
  /// `GET /api/v1/commission-tiers/by-category/{category}`
  static String commissionTierByCategory(String category) =>
      '$_v1/commission-tiers/by-category/$category';

  // Prices

  /// Path for the fuel-price collection (list all / create).
  ///
  /// `GET /api/v1/prices` · `POST /api/v1/prices`
  static const String prices = '$_v1/prices';

  /// Returns the path for looking up a fuel price by [consumptionType].
  ///
  /// `GET /api/v1/prices/by-type/{consumptionType}`
  static String priceByType(String consumptionType) =>
      '$_v1/prices/by-type/$consumptionType';

  // Categories

  /// Path for the category collection (list all / create).
  ///
  /// `GET /api/v1/categories` · `POST /api/v1/categories`
  static const String categories = '$_v1/categories';

  /// Returns the path for a single category identified by [id].
  ///
  /// `GET /api/v1/categories/{id}`
  static String category(String id) => '$_v1/categories/$id';

  // Metrics

  /// Path for retrieving aggregated platform metrics.
  ///
  /// `GET /api/v1/metrics`
  static const String metrics = '$_v1/metrics';
}
