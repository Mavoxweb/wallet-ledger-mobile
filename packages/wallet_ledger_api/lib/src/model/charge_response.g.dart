// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charge_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChargeResponseCWProxy {
  ChargeResponse payload(String payload);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChargeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChargeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ChargeResponse call({String payload});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChargeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChargeResponse.copyWith.fieldName(...)`
class _$ChargeResponseCWProxyImpl implements _$ChargeResponseCWProxy {
  const _$ChargeResponseCWProxyImpl(this._value);

  final ChargeResponse _value;

  @override
  ChargeResponse payload(String payload) => this(payload: payload);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChargeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChargeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ChargeResponse call({Object? payload = const $CopyWithPlaceholder()}) {
    return ChargeResponse(
      payload: payload == const $CopyWithPlaceholder()
          ? _value.payload
          // ignore: cast_nullable_to_non_nullable
          : payload as String,
    );
  }
}

extension $ChargeResponseCopyWith on ChargeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfChargeResponse.copyWith(...)` or like so:`instanceOfChargeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChargeResponseCWProxy get copyWith => _$ChargeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChargeResponse _$ChargeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChargeResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['payload']);
      final val = ChargeResponse(
        payload: $checkedConvert('payload', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ChargeResponseToJson(ChargeResponse instance) =>
    <String, dynamic>{'payload': instance.payload};
