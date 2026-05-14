import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storm_api_client/src/models/activity/activity_item.dart';

part 'paginated_activity_response.g.dart';

/// Paginated response wrapper for the unified activity feed.
@JsonSerializable(fieldRename: FieldRename.snake)
class PaginatedActivityResponse extends Equatable {
  const PaginatedActivityResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.remainingItems,
  });

  factory PaginatedActivityResponse.fromJson(Map<String, Object?> json) =>
      _$PaginatedActivityResponseFromJson(json);

  /// Activity items on this page.
  final List<ActivityItem> data;

  /// Current page (1-based).
  final int page;

  /// Items per page.
  final int pageSize;

  /// Total matching items across all pages.
  final int totalItems;

  /// Total number of pages.
  final int totalPages;

  /// `true` when a next page exists.
  final bool hasNextPage;

  /// `true` when a previous page exists.
  final bool hasPrevPage;

  /// Items remaining after the current page.
  final int remainingItems;

  Map<String, Object?> toJson() => _$PaginatedActivityResponseToJson(this);

  @override
  List<Object?> get props => [
    data,
    page,
    pageSize,
    totalItems,
    totalPages,
    hasNextPage,
    hasPrevPage,
    remainingItems,
  ];
}
