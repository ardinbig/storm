import 'package:account_repository/account_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

class MockStormApiClient extends Mock implements StormApiClient {}

void main() {
  late MockStormApiClient apiClient;
  late CustomerRepository repository;

  const customer = Customer(
    id: 'customer-1',
    status: 1,
    cardId: 'CARD-001',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+243000000001',
    clientCode: 'CL-001',
  );

  const customerByCard = CustomerByCardResponse(clientCode: 'CL-001');

  const registerRequest = RegisterCustomerRequest(
    cardId: 'CARD-001',
    firstName: 'Jane',
    lastName: 'Doe',
    phone: '+243000000001',
    address: 'Goma',
  );

  const updateRequest = UpdateCustomerRequest(
    firstName: 'Janet',
    phone: '+243000000009',
  );

  setUp(() {
    apiClient = MockStormApiClient();
    repository = CustomerRepository(apiClient: apiClient);
  });

  group('CustomerRepository', () {
    test(
      'agentRegisterCustomer maps payload and delegates to api client',
      () async {
        const expectedRequest = AgentRegisterCustomerRequest(
          firstName: 'John',
          lastName: 'Doe',
          phone: '+243000000000',
          cardRef: 'CARD-123',
          middleName: 'M',
          gender: 'M',
          maritalStatus: 'single',
          address: 'Goma',
          affiliation: 'Station A',
        );
        when(
          () => apiClient.agentRegisterCustomerTE(expectedRequest),
        ).thenReturn(TaskEither.right(unit));

        final result = await repository
            .agentRegisterCustomer(
              firstName: 'John',
              lastName: 'Doe',
              phone: '+243000000000',
              cardRef: 'CARD-123',
              middleName: 'M',
              gender: 'M',
              maritalStatus: 'single',
              address: 'Goma',
              affiliation: 'Station A',
            )
            .run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (_) {}, // success
        );
        verify(
          () => apiClient.agentRegisterCustomerTE(expectedRequest),
        ).called(1);
      },
    );

    test('agentRegisterCustomer supports null optional fields', () async {
      const expectedRequest = AgentRegisterCustomerRequest(
        firstName: 'John',
        lastName: 'Doe',
        phone: '+243000000000',
        cardRef: 'CARD-123',
      );
      when(
        () => apiClient.agentRegisterCustomerTE(expectedRequest),
      ).thenReturn(TaskEither.right(unit));

      final result = await repository
          .agentRegisterCustomer(
            firstName: 'John',
            lastName: 'Doe',
            phone: '+243000000000',
            cardRef: 'CARD-123',
          )
          .run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (_) {}, // success
      );
      verify(
        () => apiClient.agentRegisterCustomerTE(expectedRequest),
      ).called(1);
    });

    test(
      'agentRegisterCustomer returns StormNetworkFailure on error',
      () async {
        const expectedRequest = AgentRegisterCustomerRequest(
          firstName: 'John',
          lastName: 'Doe',
          phone: '+243000000000',
          cardRef: 'CARD-123',
        );
        when(
          () => apiClient.agentRegisterCustomerTE(expectedRequest),
        ).thenReturn(
          TaskEither.left(const StormNetworkFailure('No internet')),
        );

        final result = await repository
            .agentRegisterCustomer(
              firstName: 'John',
              lastName: 'Doe',
              phone: '+243000000000',
              cardRef: 'CARD-123',
            )
            .run();

        result.fold(
          (f) {
            expect(f, isA<StormNetworkFailure>());
            expect(f.message, 'No internet');
          },
          (_) => fail('expected Left but got Right'),
        );
        verify(
          () => apiClient.agentRegisterCustomerTE(expectedRequest),
        ).called(1);
      },
    );

    test(
      'registerCustomer forwards request and returns created customer',
      () async {
        when(
          () => apiClient.registerCustomerTE(registerRequest),
        ).thenReturn(TaskEither.right(customer));

        final result = await repository.registerCustomer(registerRequest).run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (c) => expect(c, customer),
        );
        verify(() => apiClient.registerCustomerTE(registerRequest)).called(1);
      },
    );

    test('registerCustomer returns StormApiFailure on error', () async {
      when(
        () => apiClient.registerCustomerTE(registerRequest),
      ).thenReturn(
        TaskEither.left(const StormApiFailure('Card already linked', 409)),
      );

      final result = await repository.registerCustomer(registerRequest).run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Card already linked');
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test(
      'updateCustomer forwards id and request and returns updated customer',
      () async {
        when(
          () => apiClient.updateCustomerTE('customer-1', updateRequest),
        ).thenReturn(TaskEither.right(customer));

        final result = await repository
            .updateCustomer(
              'customer-1',
              updateRequest,
            )
            .run();

        result.fold(
          (f) => fail('expected Right but got Left: $f'),
          (c) => expect(c, customer),
        );
        verify(
          () => apiClient.updateCustomerTE('customer-1', updateRequest),
        ).called(1);
      },
    );

    test('deleteCustomer delegates deletion to api client', () async {
      when(
        () => apiClient.deleteCustomerTE('customer-1'),
      ).thenReturn(TaskEither.right(unit));

      final result = await repository.deleteCustomer('customer-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (_) {}, // success
      );
      verify(() => apiClient.deleteCustomerTE('customer-1')).called(1);
    });

    test('deleteCustomer returns StormApiFailure on error', () async {
      when(
        () => apiClient.deleteCustomerTE('customer-1'),
      ).thenReturn(
        TaskEither.left(const StormApiFailure('Not found', 404)),
      );

      final result = await repository.deleteCustomer('customer-1').run();

      result.fold(
        (f) {
          expect(f, isA<StormApiFailure>());
          expect(f.message, 'Not found');
        },
        (_) => fail('expected Left but got Right'),
      );
    });

    test('findByCard returns customer lookup result', () async {
      when(
        () => apiClient.getCustomerByCardTE('CARD-001'),
      ).thenReturn(TaskEither.right(customerByCard));

      final result = await repository.findByCard('CARD-001').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (r) => expect(r, customerByCard),
      );
      verify(() => apiClient.getCustomerByCardTE('CARD-001')).called(1);
    });

    test('getCustomer returns customer by id', () async {
      when(
        () => apiClient.getCustomerTE('customer-1'),
      ).thenReturn(TaskEither.right(customer));

      final result = await repository.getCustomer('customer-1').run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (c) => expect(c, customer),
      );
      verify(() => apiClient.getCustomerTE('customer-1')).called(1);
    });

    test('listCustomers returns all customers from api client', () async {
      when(() => apiClient.listCustomersTE()).thenReturn(
        TaskEither.right([customer]),
      );

      final result = await repository.listCustomers().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, [customer]),
      );
      verify(() => apiClient.listCustomersTE()).called(1);
    });

    test('listCustomers returns empty list when no customers exist', () async {
      when(() => apiClient.listCustomersTE()).thenReturn(
        TaskEither.right([]),
      );

      final result = await repository.listCustomers().run();

      result.fold(
        (f) => fail('expected Right but got Left: $f'),
        (list) => expect(list, isEmpty),
      );
      verify(() => apiClient.listCustomersTE()).called(1);
    });
  });
}
