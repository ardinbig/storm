import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:offline_storage/offline_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Signature for a factory that opens (or creates) the SQLite database.
///
/// The opener is responsible for resolving its own path so that test
/// implementations using `sqflite_common_ffi` can avoid native channel calls
/// (`getDatabasesPath`) that require Flutter binding initialization.
typedef DatabaseOpener = Future<Database> Function();

/// {@template offline_storage}
/// Provides a SQLite-backed FIFO queue for operations that failed due to
/// connectivity.
///
/// Sensitive columns (`endpoint`, `method`, `body`) are encrypted with
/// AES-256-CBC before being written to disk. The encryption key is generated
/// once and persisted in [FlutterSecureStorage].
/// {@endtemplate}
class OfflineStorage {
  /// {@macro offline_storage}
  OfflineStorage({
    FlutterSecureStorage? secureStorage,
    this._database,
    DatabaseOpener? databaseOpener,
    this._encrypter,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _opener = databaseOpener ?? _defaultOpener;

  static const _tableName = 'pending_operations';
  static const _dbKeyStorageKey = 'storm_db_key';

  final FlutterSecureStorage _secureStorage;
  final DatabaseOpener _opener;

  Database? _database;
  Encrypter? _encrypter;

  /// Opens (or creates) the plain SQLite database at the default on-device
  /// path. Encryption is handled at the column level, not at the file level.
  static Future<Database> _defaultOpener() async {
    final dbPath = p.join(await getDatabasesPath(), 'storm_offline.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            method TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status INTEGER NOT NULL DEFAULT 0
          )
        '''),
    );
  }

  /// Initializes the storage layer.
  ///
  /// On first call:
  /// 1. Reads (or generates) a 256-bit AES key from [FlutterSecureStorage].
  /// 2. Constructs an [Encrypter] from that key.
  /// 3. Opens the SQLite database via [DatabaseOpener].
  ///
  /// Subsequent calls are no-ops.
  Future<void> init() async {
    if (_database != null && _encrypter != null) return;

    if (_encrypter == null) {
      var hexKey = await _secureStorage.read(key: _dbKeyStorageKey);
      if (hexKey == null) {
        hexKey = _generateKey();
        await _secureStorage.write(key: _dbKeyStorageKey, value: hexKey);
      }
      _encrypter = Encrypter(AES(Key.fromBase16(hexKey)));
    }

    _database ??= await _opener();
  }

  /// Generates a cryptographically random 256-bit key as a 64-char hex string.
  static String _generateKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Database get _db {
    final db = _database;
    if (db == null) {
      throw StateError('OfflineStorage has not been initialized. Call init().');
    }
    return db;
  }

  Encrypter get _enc {
    final enc = _encrypter;
    if (enc == null) {
      throw StateError('OfflineStorage has not been initialized. Call init().');
    }
    return enc;
  }

  /// Encrypts [value] with a fresh random IV.
  String _encryptValue(String value) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _enc.encrypt(value, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a value previously produced by [_encryptValue].
  String _decryptValue(String stored) {
    final colon = stored.indexOf(':');
    final iv = IV.fromBase64(stored.substring(0, colon));
    return _enc.decrypt64(stored.substring(colon + 1), iv: iv);
  }

  /// Encrypts sensitive fields then enqueues a pending operation.
  Future<void> insert(PendingOperation operation) async {
    final map = {
      ...operation.toMap(),
      'endpoint': _encryptValue(operation.endpoint),
      'method': _encryptValue(operation.method),
      'body': _encryptValue(operation.body),
    };
    await _db.insert(_tableName, map);
  }

  /// Returns all pending operations in FIFO order, with sensitive fields
  /// transparently decrypted.
  Future<List<PendingOperation>> pendingOperations() async {
    final rows = await _db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: const [0],
      orderBy: 'id ASC',
    );
    return rows.map((row) {
      final decrypted = Map<String, Object?>.from(row)
        ..['endpoint'] = _decryptValue(row['endpoint']! as String)
        ..['method'] = _decryptValue(row['method']! as String)
        ..['body'] = _decryptValue(row['body']! as String);
      return PendingOperation.fromMap(decrypted);
    }).toList();
  }

  /// Removes a single operation after successful replay.
  Future<void> remove(int id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns the number of pending operations (for badge display).
  Future<int> pendingCount() async {
    final result = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM $_tableName WHERE status = 0'),
    );
    return result ?? 0;
  }

  /// [Task]-wrapped [insert], safe to compose inside `TaskEither` chains.
  Task<void> insertTask(PendingOperation operation) =>
      Task(() => insert(operation));

  /// [Task]-wrapped [remove], safe to compose inside `TaskEither` chains.
  Task<void> removeTask(int id) => Task(() => remove(id));

  /// [Task]-wrapped [pendingCount], safe to compose inside `TaskEither` chains.
  Task<int> get pendingCountTask => Task(pendingCount);

  /// [Task]-wrapped [pendingOperations], safe to compose inside
  /// `TaskEither` chains.
  Task<List<PendingOperation>> get pendingOperationsTask =>
      Task(pendingOperations);

  /// Closes the database connection.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
