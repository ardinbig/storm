// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_activity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedActivityResponse _$PaginatedActivityResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedActivityResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
  totalItems: (json['total_items'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  hasNextPage: json['has_next_page'] as bool,
  hasPrevPage: json['has_prev_page'] as bool,
  remainingItems: (json['remaining_items'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedActivityResponseToJson(
  PaginatedActivityResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'page': instance.page,
  'page_size': instance.pageSize,
  'total_items': instance.totalItems,
  'total_pages': instance.totalPages,
  'has_next_page': instance.hasNextPage,
  'has_prev_page': instance.hasPrevPage,
  'remaining_items': instance.remainingItems,
};
