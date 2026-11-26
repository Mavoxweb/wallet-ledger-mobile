// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pix_key_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PixKeyResponseCWProxy {
  PixKeyResponse id(String id);

  PixKeyResponse type(PixKeyType type);

  PixKeyResponse value(String value);

  PixKeyResponse createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixKeyResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixKeyResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixKeyResponse call({
    String id,
    PixKeyType type,
    String value,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPixKeyResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPixKeyResponse.copyWith.fieldName(...)`
class _$PixKeyResponseCWProxyImpl implements _$PixKeyResponseCWProxy {
  const _$PixKeyResponseCWProxyImpl(this._value);

  final PixKeyResponse _value;

  @override
  PixKeyResponse id(String id) => this(id: id);

  @override
  PixKeyResponse type(PixKeyType type) => this(type: type);

  @override
  PixKeyResponse value(String value) => this(value: value);

  @override
  PixKeyResponse createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixKeyResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixKeyResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixKeyResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return PixKeyResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PixKeyType,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $PixKeyResponseCopyWith on PixKeyResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPixKeyResponse.copyWith(...)` or like so:`instanceOfPixKeyResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PixKeyResponseCWProxy get copyWith => _$PixKeyResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixKeyResponse _$PixKeyResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PixKeyResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'type', 'value', 'createdAt']);
  final val = PixKeyResponse(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert('type', (v) => $enumDecode(_$PixKeyTypeEnumMap, v)),
    value: $checkedConvert('value', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$PixKeyResponseToJson(PixKeyResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PixKeyTypeEnumMap[instance.type]!,
      'value': instance.value,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PixKeyTypeEnumMap = {
  PixKeyType.email: 'email',
  PixKeyType.phone: 'phone',
  PixKeyType.evp: 'evp',
};
