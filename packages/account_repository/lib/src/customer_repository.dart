import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';

/// {@template customer_repository}
/// Manages customer profiles and agent-initiated registration.
/// {@endtemplate}
class CustomerRepository {
  /// {@macro customer_repository}
  const CustomerRepository({required StormApiClient apiClient})
    : _apiClient = apiClient;

  final StormApiClient _apiClient;

  /// Agent registers a new customer with an NFC card.
  TaskEither<StormFailure, Unit> agentRegisterCustomer({
    required String firstName,
    required String lastName,
    required String phone,
    required String cardRef,
    String? middleName,
    String? gender,
    String? maritalStatus,
    String? address,
    String? affiliation,
  }) => _apiClient.agentRegisterCustomerTE(
    AgentRegisterCustomerRequest(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      cardRef: cardRef,
      middleName: middleName,
      gender: gender,
      maritalStatus: maritalStatus,
      address: address,
      affiliation: affiliation,
    ),
  );

  /// Registers a customer directly (admin).
  TaskEither<StormFailure, Customer> registerCustomer(
    RegisterCustomerRequest request,
  ) => _apiClient.registerCustomerTE(request);

  /// Updates an existing customer.
  TaskEither<StormFailure, Customer> updateCustomer(
    String id,
    UpdateCustomerRequest request,
  ) => _apiClient.updateCustomerTE(id, request);

  /// Deletes a customer.
  TaskEither<StormFailure, Unit> deleteCustomer(String id) =>
      _apiClient.deleteCustomerTE(id);

  /// Looks up a customer by NFC card ID.
  TaskEither<StormFailure, CustomerByCardResponse> findByCard(
    String cardId,
  ) => _apiClient.getCustomerByCardTE(cardId);

  /// Gets a single customer by [id].
  TaskEither<StormFailure, Customer> getCustomer(String id) =>
      _apiClient.getCustomerTE(id);

  /// Lists all customers.
  TaskEither<StormFailure, List<Customer>> listCustomers() =>
      _apiClient.listCustomersTE();
}
