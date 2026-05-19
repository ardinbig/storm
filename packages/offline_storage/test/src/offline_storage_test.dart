import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_storage/offline_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _testHexKey =
    '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';
final _testEncrypter = Encrypter(AES(Key.fromBase16(_testHexKey)));
const _dbKey = 'storm_db_key';

Future<Database> _openTestDb() => databaseFactoryFfi.openDatabase(
  inMemoryDatabasePath,
  options: OpenDatabaseOptions(
    version: 1,
    onCreate: (db, _) => db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0
      )
    '''),
  ),
);

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late Database database;
  late OfflineStorage offlineStorage;

  final operation = PendingOperation(
    endpoint: '/api/v1/consumptions',
    method: 'POST',
    body: '{"amount": 42}',
    createdAt: DateTime(2026, 5, 18),
  );

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    mockSecureStorage = MockFlutterSecureStorage();
    database = await _openTestDb();
    offlineStorage = OfflineStorage(
      secureStorage: mockSecureStorage,
      database: database,
      encrypter: _testEncrypter,
    );
  });

  tearDown(() async => database.close());

  group('OfflineStorage', () {
    group('init', () {
      test(
        'is a no-op when database and encrypter are already injected',
        () async {
          await offlineStorage.init();

          verifyNever(() => mockSecureStorage.read(key: any(named: 'key')));
          verifyNever(
            () => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          );
        },
      );

      test(
        'uses existing key without writing when key is already stored',
        () async {
          when(
            () => mockSecureStorage.read(key: _dbKey),
          ).thenAnswer((_) async => _testHexKey);

          final storage = OfflineStorage(
            secureStorage: mockSecureStorage,
            databaseOpener: _openTestDb,
          );
          addTearDown(storage.close);

          await storage.init();

          verify(() => mockSecureStorage.read(key: _dbKey)).called(1);
          verifyNever(
            () => mockSecureStorage.write(
              key: _dbKey,
              value: any(named: 'value'),
            ),
          );
        },
      );

      test(
        'generates and persists a new 256-bit hex key when none exists',
        () async {
          when(
            () => mockSecureStorage.read(key: _dbKey),
          ).thenAnswer((_) async => null);
          when(
            () => mockSecureStorage.write(
              key: _dbKey,
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async {});

          final storage = OfflineStorage(
            secureStorage: mockSecureStorage,
            databaseOpener: _openTestDb,
          );
          addTearDown(storage.close);

          await storage.init();

          verify(() => mockSecureStorage.read(key: _dbKey)).called(1);
          final captured = verify(
            () => mockSecureStorage.write(
              key: _dbKey,
              value: captureAny(named: 'value'),
            ),
          ).captured;
          expect(captured, hasLength(1));
          expect(
            captured.first! as String,
            matches(RegExp(r'^[0-9a-f]{64}$')),
          );
        },
      );

      test('is idempotent — second call does not re-read the key', () async {
        when(
          () => mockSecureStorage.read(key: _dbKey),
        ).thenAnswer((_) async => _testHexKey);

        final storage = OfflineStorage(
          secureStorage: mockSecureStorage,
          databaseOpener: _openTestDb,
        );
        addTearDown(storage.close);

        await storage.init();
        await storage.init();

        verify(() => mockSecureStorage.read(key: _dbKey)).called(1);
      });
    });

    group('encryption', () {
      test('stores endpoint, method and body as ciphertext on disk', () async {
        await offlineStorage.insert(operation);

        final rows = await database.query('pending_operations');
        expect(rows, hasLength(1));
        expect(rows.first['endpoint'], isNot(operation.endpoint));
        expect(rows.first['method'], isNot(operation.method));
        expect(rows.first['body'], isNot(operation.body));
        expect(
          rows.first['endpoint']! as String,
          matches(RegExp(r'^[A-Za-z0-9+/=]+:[A-Za-z0-9+/=]+$')),
        );
      });

      test(
        'pendingOperations transparently decrypts all sensitive fields',
        () async {
          await offlineStorage.insert(operation);

          final result = await offlineStorage.pendingOperations();

          expect(result.first.endpoint, operation.endpoint);
          expect(result.first.method, operation.method);
          expect(result.first.body, operation.body);
        },
      );

      test(
        'identical plaintexts produce different ciphertexts due to random IV',
        () async {
          await offlineStorage.insert(operation);
          await offlineStorage.insert(operation);

          final rows = await database.query('pending_operations');
          expect(rows[0]['endpoint'], isNot(rows[1]['endpoint']));
        },
      );

      test('non-sensitive fields are stored as plaintext', () async {
        await offlineStorage.insert(operation);

        final rows = await database.query('pending_operations');
        expect(rows.first['created_at'], operation.createdAt.toIso8601String());
        expect(rows.first['status'], 0);
      });
    });

    group('insert', () {
      test('enqueues an operation with status 0', () async {
        await offlineStorage.insert(operation);

        final pending = await offlineStorage.pendingOperations();
        expect(pending, hasLength(1));
        expect(pending.first.endpoint, operation.endpoint);
        expect(pending.first.status, 0);
      });

      test('preserves insertion order across multiple operations', () async {
        final op2 = operation.copyWith(endpoint: '/api/v1/other');

        await offlineStorage.insert(operation);
        await offlineStorage.insert(op2);

        final pending = await offlineStorage.pendingOperations();
        expect(pending[0].endpoint, operation.endpoint);
        expect(pending[1].endpoint, op2.endpoint);
      });

      test('assigns an auto-incremented id to each row', () async {
        await offlineStorage.insert(operation);
        await offlineStorage.insert(operation);

        final pending = await offlineStorage.pendingOperations();
        expect(pending[0].id, 1);
        expect(pending[1].id, 2);
      });
    });

    group('pendingOperations', () {
      test('returns empty list when queue is empty', () async {
        expect(await offlineStorage.pendingOperations(), isEmpty);
      });

      test('excludes rows with status 1 (already synced)', () async {
        await offlineStorage.insert(operation);
        final rows = await offlineStorage.pendingOperations();
        await database.update(
          'pending_operations',
          {'status': 1},
          where: 'id = ?',
          whereArgs: [rows.first.id],
        );
        await offlineStorage.insert(
          operation.copyWith(endpoint: '/api/v1/fresh'),
        );

        final result = await offlineStorage.pendingOperations();
        expect(result, hasLength(1));
        expect(result.first.endpoint, '/api/v1/fresh');
      });

      test('returns rows in FIFO (ascending id) order', () async {
        for (var i = 1; i <= 3; i++) {
          await offlineStorage.insert(
            operation.copyWith(endpoint: '/api/v1/item/$i'),
          );
        }

        final result = await offlineStorage.pendingOperations();
        expect(result.map((o) => o.endpoint).toList(), [
          '/api/v1/item/1',
          '/api/v1/item/2',
          '/api/v1/item/3',
        ]);
      });
    });

    group('remove', () {
      test('deletes the operation with the matching id', () async {
        await offlineStorage.insert(operation);
        final before = await offlineStorage.pendingOperations();

        await offlineStorage.remove(before.first.id!);

        expect(await offlineStorage.pendingOperations(), isEmpty);
      });

      test(
        'does nothing when the given id does not exist in the queue',
        () async {
          await offlineStorage.insert(operation);
          await offlineStorage.remove(9999);

          expect(await offlineStorage.pendingOperations(), hasLength(1));
        },
      );

      test(
        'removes only the targeted row when multiple operations are queued',
        () async {
          await offlineStorage.insert(operation);
          await offlineStorage.insert(operation.copyWith(endpoint: '/other'));
          final rows = await offlineStorage.pendingOperations();

          await offlineStorage.remove(rows.first.id!);

          final remaining = await offlineStorage.pendingOperations();
          expect(remaining, hasLength(1));
          expect(remaining.first.endpoint, '/other');
        },
      );
    });

    group('pendingCount', () {
      test('returns 0 for an empty queue', () async {
        expect(await offlineStorage.pendingCount(), 0);
      });

      test('reflects the current number of pending rows', () async {
        await offlineStorage.insert(operation);
        await offlineStorage.insert(operation.copyWith(endpoint: '/other'));

        expect(await offlineStorage.pendingCount(), 2);
      });

      test('excludes rows with status 1 from the count', () async {
        await offlineStorage.insert(operation);
        await offlineStorage.insert(operation.copyWith(endpoint: '/other'));
        final rows = await offlineStorage.pendingOperations();
        await database.update(
          'pending_operations',
          {'status': 1},
          where: 'id = ?',
          whereArgs: [rows.first.id],
        );

        expect(await offlineStorage.pendingCount(), 1);
      });
    });

    group('task wrappers', () {
      test('insertTask delegates to insert', () async {
        await offlineStorage.insertTask(operation).run();
        expect(await offlineStorage.pendingCount(), 1);
      });

      test('removeTask delegates to remove', () async {
        await offlineStorage.insert(operation);
        final rows = await offlineStorage.pendingOperations();

        await offlineStorage.removeTask(rows.first.id!).run();

        expect(await offlineStorage.pendingCount(), 0);
      });

      test('pendingCountTask delegates to pendingCount', () async {
        await offlineStorage.insert(operation);
        expect(await offlineStorage.pendingCountTask.run(), 1);
      });

      test('pendingOperationsTask returns decrypted operations', () async {
        await offlineStorage.insert(operation);
        final ops = await offlineStorage.pendingOperationsTask.run();
        expect(ops.first.endpoint, operation.endpoint);
      });
    });

    group('close', () {
      test('closes the database connection without error', () async {
        await offlineStorage.close();
      });

      test('allows close to be called on an already-closed instance', () async {
        await offlineStorage.close();
        await offlineStorage.close();
      });
    });

    group('uninitialized guards', () {
      test(
        'throws StateError when accessing db before init is called',
        () async {
          final uninitializedStorage = OfflineStorage(
            secureStorage: mockSecureStorage,
          );

          await expectLater(
            uninitializedStorage.pendingOperations(),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'throws StateError when encrypter is missing but database is present',
        () async {
          final storageWithoutEncrypter = OfflineStorage(
            secureStorage: mockSecureStorage,
            database: database,
          );

          await expectLater(
            storageWithoutEncrypter.insert(operation),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('_defaultOpener', () {
      test(
        'opens and creates database using the default opener '
        'when none is injected',
        () async {
          databaseFactory = databaseFactoryFfi;
          final dbPath = p.join(
            await databaseFactoryFfi.getDatabasesPath(),
            'storm_offline.db',
          );
          await databaseFactoryFfi.deleteDatabase(dbPath);
          addTearDown(() => databaseFactoryFfi.deleteDatabase(dbPath));

          when(
            () => mockSecureStorage.read(key: _dbKey),
          ).thenAnswer((_) async => _testHexKey);

          final storage = OfflineStorage(
            secureStorage: mockSecureStorage,
            encrypter: _testEncrypter,
          );
          addTearDown(storage.close);

          await storage.init();

          await storage.insert(operation);
          final ops = await storage.pendingOperations();
          expect(ops, hasLength(1));
          expect(ops.first.endpoint, operation.endpoint);
        },
      );
    });
  });
}
