// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pix_transfer_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PixTransferRequestCWProxy {
  PixTransferRequest keyType(PixKeyType keyType);

  PixTransferRequest keyValue(String keyValue);

  PixTransferRequest amountCents(int amountCents);

  PixTransferRequest description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixTransferRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixTransferRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PixTransferRequest call({
    PixKeyType keyType,
    String keyValue,
    int amountCents,
    String? description,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPixTransferRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPixTransferRequest.copyWith.fieldName(...)`
class _$PixTransferRequestCWProxyImpl implements _$PixTransferRequestCWProxy {
  const _$PixTransferRequestCWProxyImpl(this._value);

  final PixTransferRequest _value;

  @override
  PixTransferRequest keyType(PixKeyType keyType) => this(keyType: keyType);

  @override
  PixTransferRequest keyValue(String keyValue) => this(keyValue: keyValue);

  @override
  PixTransferRequest amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  PixTransferRequest description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixTransferRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixTransferRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PixTransferRequest call({
    Object? keyType = const $CopyWithPlaceholder(),
    Object? keyValue = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return PixTransferRequest(
      keyType: keyType == const $CopyWithPlaceholder()
          ? _value.keyType
          // ignore: cast_nullable_to_non_nullable
          : keyType as PixKeyType,
      keyValue: keyValue == const $CopyWithPlaceholder()
          ? _value.keyValue
          // ignore: cast_nullable_to_non_nullable
          : keyValue as String,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $PixTransferRequestCopyWith on PixTransferRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPixTransferRequest.copyWith(...)` or like so:`instanceOfPixTransferRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PixTransferRequestCWProxy get copyWith =>
      _$PixTransferRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixTransferRequest _$PixTransferRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PixTransferRequest', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'keyType',
          'keyValue',
          'amountCents',
          'description',
        ],
      );
      final val = PixTransferRequest(
        keyType: $checkedConvert(
          'keyType',
          (v) => $enumDecode(_$PixKeyTypeEnumMap, v),
        ),
        keyValue: $checkedConvert('keyValue', (v) => v as String),
        amountCents: $checkedConvert('amountCents', (v) => (v as num).toInt()),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PixTransferRequestToJson(PixTransferRequest instance) =>
    <String, dynamic>{
      'keyType': _$PixKeyTypeEnumMap[instance.keyType]!,
      'keyValue': instance.keyValue,
      'amountCents': instance.amountCents,
      'description': instance.description,
    };

const _$PixKeyTypeEnumMap = {
  PixKeyType.email: 'email',
  PixKeyType.phone: 'phone',
  PixKeyType.evp: 'evp',
};
