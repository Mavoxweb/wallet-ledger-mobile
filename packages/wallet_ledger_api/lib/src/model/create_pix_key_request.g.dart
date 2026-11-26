// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_pix_key_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreatePixKeyRequestCWProxy {
  CreatePixKeyRequest type(PixKeyType type);

  CreatePixKeyRequest value(String? value);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePixKeyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePixKeyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePixKeyRequest call({PixKeyType type, String? value});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreatePixKeyRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreatePixKeyRequest.copyWith.fieldName(...)`
class _$CreatePixKeyRequestCWProxyImpl implements _$CreatePixKeyRequestCWProxy {
  const _$CreatePixKeyRequestCWProxyImpl(this._value);

  final CreatePixKeyRequest _value;

  @override
  CreatePixKeyRequest type(PixKeyType type) => this(type: type);

  @override
  CreatePixKeyRequest value(String? value) => this(value: value);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreatePixKeyRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreatePixKeyRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreatePixKeyRequest call({
    Object? type = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return CreatePixKeyRequest(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PixKeyType,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as String?,
    );
  }
}

extension $CreatePixKeyRequestCopyWith on CreatePixKeyRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreatePixKeyRequest.copyWith(...)` or like so:`instanceOfCreatePixKeyRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreatePixKeyRequestCWProxy get copyWith =>
      _$CreatePixKeyRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePixKeyRequest _$CreatePixKeyRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreatePixKeyRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['type', 'value']);
      final val = CreatePixKeyRequest(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$PixKeyTypeEnumMap, v),
        ),
        value: $checkedConvert('value', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreatePixKeyRequestToJson(
  CreatePixKeyRequest instance,
) => <String, dynamic>{
  'type': _$PixKeyTypeEnumMap[instance.type]!,
  'value': instance.value,
};

const _$PixKeyTypeEnumMap = {
  PixKeyType.email: 'email',
  PixKeyType.phone: 'phone',
  PixKeyType.evp: 'evp',
};
