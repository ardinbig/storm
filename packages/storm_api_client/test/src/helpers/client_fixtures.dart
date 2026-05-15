import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:storm_api_client/storm_api_client.dart';
import 'package:test/test.dart';

const userInfoJson = <String, Object?>{
  'id': 'u1',
  'name': 'Test User',
  'username': 'testuser',
};

const agentInfoJson = <String, Object?>{
  'id': 'a1',
  'agent_ref': 'AGT01',
  'currency_code': 'USD',
};

const balanceResponseJson = <String, Object?>{
  'nfc_ref': 'NFC1',
  'client_code': 'CLI1',
  'amount': 100.0,
};

const nfcCardJson = <String, Object?>{'id': 'c1', 'card_id': 'CARD1'};

const customerJson = <String, Object?>{
  'id': 'cu1',
  'status': 1,
  'card_id': 'CARD1',
};

const transactionJson = <String, Object?>{'id': 't1'};

const commissionJson = <String, Object?>{
  'id': 'com1',
  'percentage': 5.0,
  'created_at': '2024-01-01T00:00:00.000Z',
};

const commissionTierJson = <String, Object?>{
  'id': 'tier1',
  'level1': 0.1,
  'level2': 0.2,
  'created_at': '2024-01-01T00:00:00.000Z',
};

const fuelPriceJson = <String, Object?>{
  'id': 'p1',
  'consumption_type': 'diesel',
  'price': 2.0,
  'price_date': '2024-01-01T00:00:00.000Z',
};

const categoryJson = <String, Object?>{
  'id': 'cat1',
  'name': 'Gold',
  'created_at': '2024-01-01T00:00:00.000Z',
};

const consumptionJson = <String, Object?>{
  'client_ref': 'CLI1',
  'consumption_type': 'diesel',
  'quantity': 5.0,
  'price': 2.0,
  'username': 'user',
  'consumption_date': '2024-01-01T00:00:00.000Z',
  'status': 1,
};

const paginatedActivityJson = <String, Object?>{
  'data': <Object?>[],
  'page': 1,
  'page_size': 10,
  'total_items': 0,
  'total_pages': 1,
  'has_next_page': false,
  'has_prev_page': false,
  'remaining_items': 0,
};

/// Wraps [data] in a successful 200 [Response] for use with `buildFakeDio`.
Response<Object?> okResponse(Object? data) => Response<Object?>(
  requestOptions: RequestOptions(path: '/'),
  data: data,
  statusCode: 200,
);

/// Asserts that [result] is a [Right] and passes its value to [check].
void assertRight<T>(
  Either<StormFailure, T> result,
  void Function(T) check,
) {
  result.fold((f) => fail('Expected Right but got Left($f)'), check);
}

/// Asserts that [result] is a [Left] and passes the failure to [check].
void assertLeft<T>(
  Either<StormFailure, T> result,
  void Function(StormFailure) check,
) {
  result.fold(check, (_) => fail('Expected Left but got Right'));
}
