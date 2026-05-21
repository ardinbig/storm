import 'package:account_repository/account_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

void main() {
  late MockStormApiClient apiClient;
  late CardRepository repository;

  const cardDetail = BalanceResponse(
    amount: 1500,
    nfcRef: 'NFC-001',
    clientCode: 'CL-1',
    network: 'MTN',
  );

  const balanceResponse = BalanceResponse(
    nfcRef: 'NFC-001',
    clientCode: 'CL-1',
    amount: 3000,
    network: 'AIRTEL',
  );

  const card = NfcCard(id: 'card-1', cardId: 'CARD-001', status: 'active');

  setUp(() {
    apiClient = MockStormApiClient();
    repository = CardRepository(apiClient: apiClient);
  });

  group('CardRepository', () {
    test('agentCheckBalance returns card detail from api client', () async {
      when(
        () => apiClient.agentCheckBalanceTE(
          'card-1',
          request: const BalanceCheckRequest(password: '1234'),
        ),
      ).thenReturn(TaskEither.right(cardDetail));

      final result = await repository
          .agentCheckBalance(
            cardId: 'card-1',
            password: '1234',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (balance) => expect(balance, cardDetail),
      );
      verify(
        () => apiClient.agentCheckBalanceTE(
          'card-1',
          request: const BalanceCheckRequest(password: '1234'),
        ),
      ).called(1);
    });

    test('agentCheckBalance returns StormApiFailure on api error', () async {
      when(
        () => apiClient.agentCheckBalanceTE(
          'missing-card',
          request: const BalanceCheckRequest(password: 'wrong'),
        ),
      ).thenReturn(
        TaskEither.left(const StormApiFailure('Card not found', 404)),
      );

      final result = await repository
          .agentCheckBalance(
            cardId: 'missing-card',
            password: 'wrong',
          )
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Card not found');
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test(
      'customerCheckBalance maps password into request and returns balance',
      () async {
        when(
          () => apiClient.checkBalanceTE(
            nfcRef: 'NFC-001',
            request: const BalanceCheckRequest(password: '1234'),
          ),
        ).thenReturn(TaskEither.right(balanceResponse));

        final result = await repository
            .customerCheckBalance(
              nfcRef: 'NFC-001',
              password: '1234',
            )
            .run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (balance) => expect(balance, balanceResponse),
        );
        verify(
          () => apiClient.checkBalanceTE(
            nfcRef: 'NFC-001',
            request: const BalanceCheckRequest(password: '1234'),
          ),
        ).called(1);
      },
    );

    test('customerCheckBalance returns StormNetworkFailure on error', () async {
      when(
        () => apiClient.checkBalanceTE(
          nfcRef: 'NFC-001',
          request: const BalanceCheckRequest(password: 'wrong'),
        ),
      ).thenReturn(
        TaskEither.left(const StormNetworkFailure('No internet')),
      );

      final result = await repository
          .customerCheckBalance(
            nfcRef: 'NFC-001',
            password: 'wrong',
          )
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormNetworkFailure>());
          expect(f.message, 'No internet');
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test('createStagingCard maps card id and returns created card', () async {
      when(
        () =>
            apiClient.createCardTE(const CreateCardRequest(cardId: 'CARD-NEW')),
      ).thenReturn(TaskEither.right(card));

      final result = await repository
          .createStagingCard(
            cardId: 'CARD-NEW',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (c) => expect(c, card),
      );
      verify(
        () =>
            apiClient.createCardTE(const CreateCardRequest(cardId: 'CARD-NEW')),
      ).called(1);
    });

    test('createStagingCard returns StormApiFailure on duplicate', () async {
      when(
        () =>
            apiClient.createCardTE(const CreateCardRequest(cardId: 'CARD-DUP')),
      ).thenReturn(
        TaskEither.left(const StormApiFailure('Card already exists', 409)),
      );

      final result = await repository
          .createStagingCard(
            cardId: 'CARD-DUP',
          )
          .run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Card already exists');
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test('listCards returns list of cards from api client', () async {
      when(() => apiClient.listCardsTE()).thenReturn(
        TaskEither.right([card]),
      );

      final result = await repository.listCards().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (cards) => expect(cards, [card]),
      );
      verify(() => apiClient.listCardsTE()).called(1);
    });

    test('listCards returns empty list when no cards are available', () async {
      when(() => apiClient.listCardsTE()).thenReturn(
        TaskEither.right([]),
      );

      final result = await repository.listCards().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (cards) => expect(cards, isEmpty),
      );
      verify(() => apiClient.listCardsTE()).called(1);
    });

    test('getCard returns card by id', () async {
      when(() => apiClient.getCardTE('card-1')).thenReturn(
        TaskEither.right(card),
      );

      final result = await repository.getCard('card-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (c) => expect(c, card),
      );
      verify(() => apiClient.getCardTE('card-1')).called(1);
    });

    test('getCard returns StormApiFailure for unknown id', () async {
      when(() => apiClient.getCardTE('missing-id')).thenReturn(
        TaskEither.left(const StormApiFailure('Not found', 404)),
      );

      final result = await repository.getCard('missing-id').run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Not found');
        },
        (_) => fail('expected Left but got Right'),
      );
      verify(() => apiClient.getCardTE('missing-id')).called(1);
    });
  });
}
