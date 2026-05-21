import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template agent_repository}
/// Manages agent accounts, history, and password operations.
/// {@endtemplate}
class AgentRepository {
  /// {@macro agent_repository}
  const AgentRepository({required StormApiClient apiClient})
    : _apiClient = apiClient;

  final StormApiClient _apiClient;

  /// Lists all agents.
  TaskEither<StormFailure, List<AgentInfo>> listAgents() =>
      _apiClient.listAgentsTE();

  /// Gets a single agent by [id].
  TaskEither<StormFailure, AgentInfo> getAgent(String id) =>
      _apiClient.getAgentTE(id);

  /// Creates a new agent.
  TaskEither<StormFailure, AgentInfo> createAgent({
    required String agentRef,
    required String password,
    String? name,
    String? currencyCode,
  }) => _apiClient.createAgentTE(
    CreateAgentRequest(
      agentRef: agentRef,
      password: password,
      name: name,
      currencyCode: currencyCode,
    ),
  );

  /// Deletes an agent by [id].
  TaskEither<StormFailure, Unit> deleteAgent(String id) =>
      _apiClient.deleteAgentTE(id);

  /// Updates an agent's profile fields (e.g. name, currency).
  ///
  /// All fields in [request] are optional, only non-null values are sent.
  TaskEither<StormFailure, AgentInfo> updateAgent(
    String id,
    UpdateAgentRequest request,
  ) => _apiClient.updateAgentTE(id, request);

  /// Updates an agent's password.
  TaskEither<StormFailure, Unit> updatePassword({
    required String agentRef,
    required String lastPassword,
    required String newPassword,
  }) => _apiClient.updateAgentPasswordTE(
    UpdateAgentPasswordRequest(
      agentRef: agentRef,
      lastPassword: lastPassword,
      newPassword: newPassword,
    ),
  );

  /// Returns the transaction history for a specific agent.
  TaskEither<StormFailure, List<AgentHistoryRow>> getHistory(String agentId) =>
      _apiClient.agentHistoryTE(agentId);
}
