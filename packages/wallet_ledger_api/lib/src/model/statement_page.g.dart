// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StatementPageCWProxy {
  StatementPage items(List<StatementItem> items);

  StatementPage nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatementPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatementPage(...).copyWith(id: 12, name: "My name")
  /// ````
  StatementPage call({List<StatementItem> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStatementPage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStatementPage.copyWith.fieldName(...)`
class _$StatementPageCWProxyImpl implements _$StatementPageCWProxy {
  const _$StatementPageCWProxyImpl(this._value);

  final StatementPage _value;

  @override
  StatementPage items(List<StatementItem> items) => this(items: items);

  @override
  StatementPage nextCursor(String? nextCursor) => this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatementPage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatementPage(...).copyWith(id: 12, name: "My name")
  /// ````
  StatementPage call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return StatementPage(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<StatementItem>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $StatementPageCopyWith on StatementPage {
  /// Returns a callable class that can be used as follows: `instanceOfStatementPage.copyWith(...)` or like so:`instanceOfStatementPage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StatementPageCWProxy get copyWith => _$StatementPageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatementPage _$StatementPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StatementPage', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'nextCursor']);
      final val = StatementPage(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => StatementItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('nextCursor', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$StatementPageToJson(StatementPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
    };
