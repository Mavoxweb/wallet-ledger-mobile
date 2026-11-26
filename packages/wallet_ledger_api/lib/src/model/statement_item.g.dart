// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StatementItemCWProxy {
  StatementItem postingId(int postingId);

  StatementItem transactionId(String transactionId);

  StatementItem type(TransactionType type);

  StatementItem direction(Direction direction);

  StatementItem amountCents(int amountCents);

  StatementItem counterpartyMaskedName(String? counterpartyMaskedName);

  StatementItem description(String? description);

  StatementItem createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatementItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatementItem(...).copyWith(id: 12, name: "My name")
  /// ````
  StatementItem call({
    int postingId,
    String transactionId,
    TransactionType type,
    Direction direction,
    int amountCents,
    String? counterpartyMaskedName,
    String? description,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStatementItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStatementItem.copyWith.fieldName(...)`
class _$StatementItemCWProxyImpl implements _$StatementItemCWProxy {
  const _$StatementItemCWProxyImpl(this._value);

  final StatementItem _value;

  @override
  StatementItem postingId(int postingId) => this(postingId: postingId);

  @override
  StatementItem transactionId(String transactionId) =>
      this(transactionId: transactionId);

  @override
  StatementItem type(TransactionType type) => this(type: type);

  @override
  StatementItem direction(Direction direction) => this(direction: direction);

  @override
  StatementItem amountCents(int amountCents) => this(amountCents: amountCents);

  @override
  StatementItem counterpartyMaskedName(String? counterpartyMaskedName) =>
      this(counterpartyMaskedName: counterpartyMaskedName);

  @override
  StatementItem description(String? description) =>
      this(description: description);

  @override
  StatementItem createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StatementItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StatementItem(...).copyWith(id: 12, name: "My name")
  /// ````
  StatementItem call({
    Object? postingId = const $CopyWithPlaceholder(),
    Object? transactionId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? counterpartyMaskedName = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return StatementItem(
      postingId: postingId == const $CopyWithPlaceholder()
          ? _value.postingId
          // ignore: cast_nullable_to_non_nullable
          : postingId as int,
      transactionId: transactionId == const $CopyWithPlaceholder()
          ? _value.transactionId
          // ignore: cast_nullable_to_non_nullable
          : transactionId as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TransactionType,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as Direction,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      counterpartyMaskedName:
          counterpartyMaskedName == const $CopyWithPlaceholder()
          ? _value.counterpartyMaskedName
          // ignore: cast_nullable_to_non_nullable
          : counterpartyMaskedName as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $StatementItemCopyWith on StatementItem {
  /// Returns a callable class that can be used as follows: `instanceOfStatementItem.copyWith(...)` or like so:`instanceOfStatementItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StatementItemCWProxy get copyWith => _$StatementItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatementItem _$StatementItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StatementItem', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'postingId',
          'transactionId',
          'type',
          'direction',
          'amountCents',
          'counterpartyMaskedName',
          'description',
          'createdAt',
        ],
      );
      final val = StatementItem(
        postingId: $checkedConvert('postingId', (v) => (v as num).toInt()),
        transactionId: $checkedConvert('transactionId', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$TransactionTypeEnumMap, v),
        ),
        direction: $checkedConvert(
          'direction',
          (v) => $enumDecode(_$DirectionEnumMap, v),
        ),
        amountCents: $checkedConvert('amountCents', (v) => (v as num).toInt()),
        counterpartyMaskedName: $checkedConvert(
          'counterpartyMaskedName',
          (v) => v as String?,
        ),
        description: $checkedConvert('description', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StatementItemToJson(StatementItem instance) =>
    <String, dynamic>{
      'postingId': instance.postingId,
      'transactionId': instance.transactionId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'direction': _$DirectionEnumMap[instance.direction]!,
      'amountCents': instance.amountCents,
      'counterpartyMaskedName': instance.counterpartyMaskedName,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.deposit: 'deposit',
  TransactionType.transfer: 'transfer',
  TransactionType.reversal: 'reversal',
};

const _$DirectionEnumMap = {Direction.in_: 'in', Direction.out_: 'out'};
