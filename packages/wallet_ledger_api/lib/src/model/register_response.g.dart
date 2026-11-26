// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegisterResponseCWProxy {
  RegisterResponse userId(String userId);

  RegisterResponse accountId(String accountId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterResponse call({String userId, String accountId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRegisterResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRegisterResponse.copyWith.fieldName(...)`
class _$RegisterResponseCWProxyImpl implements _$RegisterResponseCWProxy {
  const _$RegisterResponseCWProxyImpl(this._value);

  final RegisterResponse _value;

  @override
  RegisterResponse userId(String userId) => this(userId: userId);

  @override
  RegisterResponse accountId(String accountId) => this(accountId: accountId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RegisterResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RegisterResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RegisterResponse call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? accountId = const $CopyWithPlaceholder(),
  }) {
    return RegisterResponse(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      accountId: accountId == const $CopyWithPlaceholder()
          ? _value.accountId
          // ignore: cast_nullable_to_non_nullable
          : accountId as String,
    );
  }
}

extension $RegisterResponseCopyWith on RegisterResponse {
  /// Returns a callable class that can be used as follows: `instanceOfRegisterResponse.copyWith(...)` or like so:`instanceOfRegisterResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegisterResponseCWProxy get copyWith => _$RegisterResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegisterResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['userId', 'accountId']);
      final val = RegisterResponse(
        userId: $checkedConvert('userId', (v) => v as String),
        accountId: $checkedConvert('accountId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'accountId': instance.accountId,
    };
