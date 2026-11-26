// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_charge_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateChargeRequestCWProxy {
  CreateChargeRequest keyId(String keyId);

  CreateChargeRequest amountCents(int? amountCents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateChargeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateChargeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateChargeRequest call({String keyId, int? amountCents});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateChargeRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateChargeRequest.copyWith.fieldName(...)`
class _$CreateChargeRequestCWProxyImpl implements _$CreateChargeRequestCWProxy {
  const _$CreateChargeRequestCWProxyImpl(this._value);

  final CreateChargeRequest _value;

  @override
  CreateChargeRequest keyId(String keyId) => this(keyId: keyId);

  @override
  CreateChargeRequest amountCents(int? amountCents) =>
      this(amountCents: amountCents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateChargeRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateChargeRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateChargeRequest call({
    Object? keyId = const $CopyWithPlaceholder(),
    Object? amountCents = const $CopyWithPlaceholder(),
  }) {
    return CreateChargeRequest(
      keyId: keyId == const $CopyWithPlaceholder()
          ? _value.keyId
          // ignore: cast_nullable_to_non_nullable
          : keyId as String,
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int?,
    );
  }
}

extension $CreateChargeRequestCopyWith on CreateChargeRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateChargeRequest.copyWith(...)` or like so:`instanceOfCreateChargeRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateChargeRequestCWProxy get copyWith =>
      _$CreateChargeRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChargeRequest _$CreateChargeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateChargeRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['keyId', 'amountCents']);
      final val = CreateChargeRequest(
        keyId: $checkedConvert('keyId', (v) => v as String),
        amountCents: $checkedConvert(
          'amountCents',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CreateChargeRequestToJson(
  CreateChargeRequest instance,
) => <String, dynamic>{
  'keyId': instance.keyId,
  'amountCents': instance.amountCents,
};
