/// A serialized API call queued while offline.
class PendingOperation {
  const PendingOperation({
    required this.endpoint,
    required this.method,
    required this.body,
    required this.createdAt,
    this.id,
    this.status = 0,
  });

  factory PendingOperation.fromMap(Map<String, Object?> map) {
    return PendingOperation(
      id: map['id']! as int,
      endpoint: map['endpoint']! as String,
      method: map['method']! as String,
      body: map['body']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      status: (map['status'] as int?) ?? 0,
    );
  }

  final int? id;

  /// e.g. `/api/v1/consumptions`
  final String endpoint;

  /// `POST`, `PUT`, etc.
  final String method;

  /// JSON-encoded request body.
  final String body;

  final DateTime createdAt;

  /// 0 = pending/offline, 1 = synced.
  final int status;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'endpoint': endpoint,
    'method': method,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'status': status,
  };

  /// Returns a copy with the provided fields replaced.
  PendingOperation copyWith({
    int? id,
    String? endpoint,
    String? method,
    String? body,
    DateTime? createdAt,
    int? status,
  }) => PendingOperation(
    id: id ?? this.id,
    endpoint: endpoint ?? this.endpoint,
    method: method ?? this.method,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );
}
