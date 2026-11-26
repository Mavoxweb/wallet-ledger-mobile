// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pix_key_lookup_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PixKeyLookupResponseCWProxy {
  PixKeyLookupResponse keyType(PixKeyType keyType);

  PixKeyLookupResponse maskedName(String maskedName);

  PixKeyLookupResponse maskedCpf(String maskedCpf);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixKeyLookupResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixKeyLookupResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixKeyLookupResponse call({
    PixKeyType keyType,
    String maskedName,
    String maskedCpf,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPixKeyLookupResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPixKeyLookupResponse.copyWith.fieldName(...)`
class _$PixKeyLookupResponseCWProxyImpl
    implements _$PixKeyLookupResponseCWProxy {
  const _$PixKeyLookupResponseCWProxyImpl(this._value);

  final PixKeyLookupResponse _value;

  @override
  PixKeyLookupResponse keyType(PixKeyType keyType) => this(keyType: keyType);

  @override
  PixKeyLookupResponse maskedName(String maskedName) =>
      this(maskedName: maskedName);

  @override
  PixKeyLookupResponse maskedCpf(String maskedCpf) =>
      this(maskedCpf: maskedCpf);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PixKeyLookupResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PixKeyLookupResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PixKeyLookupResponse call({
    Object? keyType = const $CopyWithPlaceholder(),
    Object? maskedName = const $CopyWithPlaceholder(),
    Object? maskedCpf = const $CopyWithPlaceholder(),
  }) {
    return PixKeyLookupResponse(
      keyType: keyType == const $CopyWithPlaceholder()
          ? _value.keyType
          // ignore: cast_nullable_to_non_nullable
          : keyType as PixKeyType,
      maskedName: maskedName == const $CopyWithPlaceholder()
          ? _value.maskedName
          // ignore: cast_nullable_to_non_nullable
          : maskedName as String,
      maskedCpf: maskedCpf == const $CopyWithPlaceholder()
          ? _value.maskedCpf
          // ignore: cast_nullable_to_non_nullable
          : maskedCpf as String,
    );
  }
}

extension $PixKeyLookupResponseCopyWith on PixKeyLookupResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPixKeyLookupResponse.copyWith(...)` or like so:`instanceOfPixKeyLookupResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PixKeyLookupResponseCWProxy get copyWith =>
      _$PixKeyLookupResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixKeyLookupResponse _$PixKeyLookupResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PixKeyLookupResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['keyType', 'maskedName', 'maskedCpf']);
  final val = PixKeyLookupResponse(
    keyType: $checkedConvert(
      'keyType',
      (v) => $enumDecode(_$PixKeyTypeEnumMap, v),
    ),
    maskedName: $checkedConvert('maskedName', (v) => v as String),
    maskedCpf: $checkedConvert('maskedCpf', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PixKeyLookupResponseToJson(
  PixKeyLookupResponse instance,
) => <String, dynamic>{
  'keyType': _$PixKeyTypeEnumMap[instance.keyType]!,
  'maskedName': instance.maskedName,
  'maskedCpf': instance.maskedCpf,
};

const _$PixKeyTypeEnumMap = {
  PixKeyType.email: 'email',
  PixKeyType.phone: 'phone',
  PixKeyType.evp: 'evp',
};
