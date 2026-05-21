import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

void main() {
  group('StormApiClient — agents', () {
    group('listAgentsTE', () {
      test('returns list of AgentInfo on success', () async {
        final dio = buildFakeDio(okResponse(<Object?>[agentInfoJson]));
        final result = await buildFakeClient(dio).listAgentsTE().run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.agentRef, 'AGT01');
        });
      });
    });

    group('getAgentTE', () {
      test('returns AgentInfo on success', () async {
        final dio = buildFakeDio(okResponse(agentInfoJson));
        final result = await buildFakeClient(dio).getAgentTE('a1').run();
        assertRight(result, (v) => expect(v.id, 'a1'));
      });
    });

    group('createAgentTE', () {
      test('returns AgentInfo on success', () async {
        final dio = buildFakeDio(okResponse(agentInfoJson));
        final result = await buildFakeClient(dio)
            .createAgentTE(
              const CreateAgentRequest(agentRef: 'AGT01', password: 'pass'),
            )
            .run();
        assertRight(result, (v) => expect(v.agentRef, 'AGT01'));
      });
    });

    group('deleteAgentTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio).deleteAgentTE('a1').run();
        assertRight(result, (v) => expect(v, unit));
      });
    });

    group('updateAgentTE', () {
      test('returns updated AgentInfo on success', () async {
        final dio = buildFakeDio(
          okResponse({...agentInfoJson, 'name': 'Updated'}),
        );
        final result = await buildFakeClient(
          dio,
        ).updateAgentTE('a1', const UpdateAgentRequest(name: 'Updated')).run();
        assertRight(result, (v) => expect(v.name, 'Updated'));
      });
    });

    group('updateAgentPasswordTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio)
            .updateAgentPasswordTE(
              const UpdateAgentPasswordRequest(
                agentRef: 'AGT01',
                lastPassword: 'old',
                newPassword: 'new',
              ),
            )
            .run();
        assertRight(result, (v) => expect(v, unit));
      });
    });

    group('agentHistoryTE', () {
      test('returns list of AgentHistoryRow on success', () async {
        final dio = buildFakeDio(
          okResponse(<Object?>[
            <String, Object?>{'id': 'h1'},
          ]),
        );
        final result = await buildFakeClient(dio).agentHistoryTE('a1').run();
        assertRight(result, (v) {
          expect(v, hasLength(1));
          expect(v.first.id, 'h1');
        });
      });
    });

    group('agentCheckBalanceTE', () {
      test('returns BalanceResponse on success', () async {
        final dio = buildFakeDio(okResponse(balanceResponseJson));
        final result = await buildFakeClient(dio)
            .agentCheckBalanceTE(
              'NFC1',
              request: const BalanceCheckRequest(password: 'pin'),
            )
            .run();
        assertRight(result, (v) => expect(v.amount, 100.0));
      });
    });

    group('agentRegisterCustomerTE', () {
      test('returns unit on success', () async {
        final dio = buildFakeDio(okResponse(null));
        final result = await buildFakeClient(dio)
            .agentRegisterCustomerTE(
              const AgentRegisterCustomerRequest(
                firstName: 'John',
                lastName: 'Doe',
                phone: '0600000001',
                cardRef: 'CARD1',
              ),
            )
            .run();
        assertRight(result, (v) => expect(v, unit));
      });
    });
  });
}
