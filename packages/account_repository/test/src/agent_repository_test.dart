import 'package:account_repository/account_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

void main() {
  late MockStormApiClient apiClient;
  late AgentRepository repository;

  const agentInfo = AgentInfo(
    id: 'agent-1',
    agentRef: 'AGT-001',
    currencyCode: 'CDF',
    name: 'Agent One',
    balance: 1200,
  );

  setUp(() {
    apiClient = MockStormApiClient();
    repository = AgentRepository(apiClient: apiClient);
  });

  group('AgentRepository', () {
    test('listAgents returns agents from api client', () async {
      when(() => apiClient.listAgentsTE()).thenReturn(
        TaskEither.right([agentInfo]),
      );

      final result = await repository.listAgents().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (agents) => expect(agents, [agentInfo]),
      );
      verify(() => apiClient.listAgentsTE()).called(1);
    });

    test('listAgents returns StormApiFailure on api error', () async {
      when(() => apiClient.listAgentsTE()).thenReturn(
        TaskEither.left(const StormApiFailure('Server error', 500)),
      );

      final result = await repository.listAgents().run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Server error');
          expect((f as StormApiFailure).statusCode, 500);
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.listAgentsTE()).called(1);
    });

    test('getAgent returns matching agent by id', () async {
      when(() => apiClient.getAgentTE('agent-1')).thenReturn(
        TaskEither.right(agentInfo),
      );

      final result = await repository.getAgent('agent-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (agent) => expect(agent, agentInfo),
      );
      verify(() => apiClient.getAgentTE('agent-1')).called(1);
    });

    test('getAgent returns StormApiFailure for unknown agent', () async {
      when(() => apiClient.getAgentTE('missing-agent')).thenReturn(
        TaskEither.left(const StormApiFailure('Agent not found', 404)),
      );

      final result = await repository.getAgent('missing-agent').run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Agent not found');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.getAgentTE('missing-agent')).called(1);
    });

    test('createAgent sends full payload and returns created agent', () async {
      const expectedRequest = CreateAgentRequest(
        agentRef: 'AGT-002',
        password: 'secret',
        name: 'Agent Two',
        currencyCode: 'USD',
      );

      when(() => apiClient.createAgentTE(expectedRequest)).thenReturn(
        TaskEither.right(agentInfo),
      );

      final result = await repository
          .createAgent(
            agentRef: 'AGT-002',
            password: 'secret',
            name: 'Agent Two',
            currencyCode: 'USD',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (agent) => expect(agent, agentInfo),
      );
      verify(() => apiClient.createAgentTE(expectedRequest)).called(1);
    });

    test('createAgent allows null optional fields', () async {
      const expectedRequest = CreateAgentRequest(
        agentRef: 'AGT-003',
        password: 'top-secret',
      );

      when(() => apiClient.createAgentTE(expectedRequest)).thenReturn(
        TaskEither.right(agentInfo),
      );

      final result = await repository
          .createAgent(
            agentRef: 'AGT-003',
            password: 'top-secret',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (agent) => expect(agent, agentInfo),
      );
      verify(() => apiClient.createAgentTE(expectedRequest)).called(1);
    });

    test('createAgent returns StormNetworkFailure on network error', () async {
      const expectedRequest = CreateAgentRequest(
        agentRef: 'AGT-004',
        password: 'top-secret',
      );

      when(() => apiClient.createAgentTE(expectedRequest)).thenReturn(
        TaskEither.left(const StormNetworkFailure('Connection timed out')),
      );

      final result = await repository
          .createAgent(
            agentRef: 'AGT-004',
            password: 'top-secret',
          )
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'Connection timed out');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.createAgentTE(expectedRequest)).called(1);
    });

    test('deleteAgent delegates deletion to api client', () async {
      when(() => apiClient.deleteAgentTE('agent-1')).thenReturn(
        TaskEither.right(unit),
      );

      final result = await repository.deleteAgent('agent-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (_) {}, // success — Unit result
      );
      verify(() => apiClient.deleteAgentTE('agent-1')).called(1);
    });

    test('deleteAgent returns StormApiFailure when deletion fails', () async {
      when(() => apiClient.deleteAgentTE('agent-1')).thenReturn(
        TaskEither.left(const StormApiFailure('Forbidden', 403)),
      );

      final result = await repository.deleteAgent('agent-1').run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Forbidden');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.deleteAgentTE('agent-1')).called(1);
    });

    test('updatePassword maps fields to update request', () async {
      const expectedRequest = UpdateAgentPasswordRequest(
        agentRef: 'AGT-001',
        lastPassword: 'old-pass',
        newPassword: 'new-pass',
      );

      when(() => apiClient.updateAgentPasswordTE(expectedRequest)).thenReturn(
        TaskEither.right(unit),
      );

      final result = await repository
          .updatePassword(
            agentRef: 'AGT-001',
            lastPassword: 'old-pass',
            newPassword: 'new-pass',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (_) {}, // success
      );
      verify(() => apiClient.updateAgentPasswordTE(expectedRequest)).called(1);
    });

    test(
      'updatePassword returns StormApiFailure for invalid current password',
      () async {
        const expectedRequest = UpdateAgentPasswordRequest(
          agentRef: 'AGT-001',
          lastPassword: 'bad-pass',
          newPassword: 'new-pass',
        );

        when(
          () => apiClient.updateAgentPasswordTE(expectedRequest),
        ).thenReturn(
          TaskEither.left(
            const StormApiFailure('Current password is invalid', 400),
          ),
        );

        final result = await repository
            .updatePassword(
              agentRef: 'AGT-001',
              lastPassword: 'bad-pass',
              newPassword: 'new-pass',
            )
            .run();

        result.fold(
          (f) {
            expect(f, isA<StormApiFailure>());
            expect(f.message, 'Current password is invalid');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(
          () => apiClient.updateAgentPasswordTE(expectedRequest),
        ).called(1);
      },
    );

    test('getHistory returns transaction history rows', () async {
      final history = [
        AgentHistoryRow(
          id: 'tx-1',
          amount: 100,
          client: 'Jane',
          currencyCode: 'CDF',
          date: DateTime(2026),
          transactionType: 'WITHDRAWAL',
        ),
      ];

      when(() => apiClient.agentHistoryTE('agent-1')).thenReturn(
        TaskEither.right(history),
      );

      final result = await repository.getHistory('agent-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (rows) => expect(rows, history),
      );
      verify(() => apiClient.agentHistoryTE('agent-1')).called(1);
    });

    test(
      'getHistory returns empty list when agent has no transactions',
      () async {
        when(() => apiClient.agentHistoryTE('agent-1')).thenReturn(
          TaskEither.right([]),
        );

        final result = await repository.getHistory('agent-1').run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (rows) => expect(rows, isEmpty),
        );
        verify(() => apiClient.agentHistoryTE('agent-1')).called(1);
      },
    );

    test('getHistory returns StormNetworkFailure on network error', () async {
      when(() => apiClient.agentHistoryTE('agent-1')).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final result = await repository.getHistory('agent-1').run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'No internet');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.agentHistoryTE('agent-1')).called(1);
    });

    test(
      'updateAgent delegates to api client and returns updated agent',
      () async {
        const request = UpdateAgentRequest(
          name: 'Agent Updated',
          currencyCode: 'USD',
        );

        when(() => apiClient.updateAgentTE('agent-1', request)).thenReturn(
          TaskEither.right(agentInfo),
        );

        final result = await repository.updateAgent('agent-1', request).run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (agent) => expect(agent, agentInfo),
        );
        verify(() => apiClient.updateAgentTE('agent-1', request)).called(1);
      },
    );

    test('updateAgent passes empty request for no-op update', () async {
      const request = UpdateAgentRequest();

      when(() => apiClient.updateAgentTE('agent-1', request)).thenReturn(
        TaskEither.right(agentInfo),
      );

      final result = await repository.updateAgent('agent-1', request).run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (agent) => expect(agent, agentInfo),
      );
      verify(() => apiClient.updateAgentTE('agent-1', request)).called(1);
    });

    test('updateAgent returns StormApiFailure when agent not found', () async {
      const request = UpdateAgentRequest(name: 'Ghost');

      when(
        () => apiClient.updateAgentTE('unknown-agent', request),
      ).thenReturn(
        TaskEither.left(const StormApiFailure('Agent not found', 404)),
      );

      final result = await repository
          .updateAgent('unknown-agent', request)
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Agent not found');
          expect((f as StormApiFailure).statusCode, 404);
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.updateAgentTE('unknown-agent', request)).called(1);
    });

    test(
      'updateAgent returns StormNetworkFailure on connectivity failure',
      () async {
        const request = UpdateAgentRequest(name: 'X');

        when(() => apiClient.updateAgentTE('agent-1', request)).thenReturn(
          TaskEither.left(const StormNetworkFailure('timeout')),
        );

        final result = await repository.updateAgent('agent-1', request).run();

        result.fold(
          (f) {
            expect(f, isA<StormNetworkFailure>());
          },
          (_) => fail('expected Left but got Right'),
        );
      },
    );
  });
}
