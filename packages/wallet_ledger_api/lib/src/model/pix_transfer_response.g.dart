// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pix_transfer_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PixTransferResponseCWProxy {
  PixTransferResponse transactionId(String transactionId);

  PixTransferResponse amountCents(int amountCents);

  PixTransferResponse recipientMaskedName(String recipientMaskedName);

  PixTransferResponse balanceCents(int balanceCents);

  PixTransferResponse createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixTransferResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixTransferResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixTransferResponse call({
    String transactionId,
    int amountCents,
    String recipientMaskedName,
    int balanceCents,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPixTransferResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPixTransferResponse.copyWith.fieldName(...)`
class _$PixTransferResponseCWProxyImpl implements _$PixTransferResponseCWProxy {
  const _$PixTransferResponseCWProxyImpl(this._value);

  final PixTransferResponse _value;

  @override
  PixTransferResponse transactionId(String transactionId) =>
      this(transactionId: transactionId);

  @override
  PixTransferResponse amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  PixTransferResponse recipientMaskedName(String recipientMaskedName) =>
      this(recipientMaskedName: recipientMaskedName);

  @override
  PixTransferResponse balanceCents(int balanceCents) =>
      this(balanceCents: balanceCents);

  @override
  PixTransferResponse createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixTransferResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixTransferResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixTransferResponse call({
    Object? transactionId = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? recipientMaskedName = const $CopyWithPlaceholder(),
    Object? balanceCents = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return PixTransferResponse(
      transactionId: transactionId == const $CopyWithPlaceholder()
          ? _value.transactionId
          // ignore: cast_nullable_to_non_nullable
          : transactionId as String,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      recipientMaskedName: recipientMaskedName == const $CopyWithPlaceholder()
          ? _value.recipientMaskedName
          // ignore: cast_nullable_to_non_nullable
          : recipientMaskedName as String,
      balanceCents: balanceCents == const $CopyWithPlaceholder()
          ? _value.balanceCents
          // ignore: cast_nullable_to_non_nullable
          : balanceCents as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $PixTransferResponseCopyWith on PixTransferResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPixTransferResponse.copyWith(...)` or like so:`instanceOfPixTransferResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PixTransferResponseCWProxy get copyWith =>
      _$PixTransferResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixTransferResponse _$PixTransferResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PixTransferResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'transactionId',
      'amountCents',
      'recipientMaskedName',
      'balanceCents',
      'createdAt',
    ],
  );
  final val = PixTransferResponse(
    transactionId: $checkedConvert('transactionId', (v) => v as String),
    amountCents: $checkedConvert('amountCents', (v) => (v as num).toInt()),
    recipientMaskedName: $checkedConvert(
      'recipientMaskedName',
      (v) => v as String,
    ),
    balanceCents: $checkedConvert('balanceCents', (v) => (v as num).toInt()),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$PixTransferResponseToJson(
  PixTransferResponse instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'amountCents': instance.amountCents,
  'recipientMaskedName': instance.recipientMaskedName,
  'balanceCents': instance.balanceCents,
  'createdAt': instance.createdAt.toIso8601String(),
};
