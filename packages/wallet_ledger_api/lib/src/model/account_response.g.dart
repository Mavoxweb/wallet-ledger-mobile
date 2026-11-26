// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AccountResponseCWProxy {
  AccountResponse accountId(String accountId);

  AccountResponse status(AccountStatus status);

  AccountResponse balanceCents(int balanceCents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountResponse call({
    String accountId,
    AccountStatus status,
    int balanceCents,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAccountResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAccountResponse.copyWith.fieldName(...)`
class _$AccountResponseCWProxyImpl implements _$AccountResponseCWProxy {
  const _$AccountResponseCWProxyImpl(this._value);

  final AccountResponse _value;

  @override
  AccountResponse accountId(String accountId) => this(accountId: accountId);

  @override
  AccountResponse status(AccountStatus status) => this(status: status);

  @override
  AccountResponse balanceCents(int balanceCents) =>
      this(balanceCents: balanceCents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AccountResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AccountResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AccountResponse call({
    Object? accountId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? balanceCents = const $CopyWithPlaceholder(),
  }) {
    return AccountResponse(
      accountId: accountId == const $CopyWithPlaceholder()
          ? _value.accountId
          // ignore: cast_nullable_to_non_nullable
          : accountId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AccountStatus,
      balanceCents: balanceCents == const $CopyWithPlaceholder()
          ? _value.balanceCents
          // ignore: cast_nullable_to_non_nullable
          : balanceCents as int,
    );
  }
}

extension $AccountResponseCopyWith on AccountResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAccountResponse.copyWith(...)` or like so:`instanceOfAccountResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AccountResponseCWProxy get copyWith => _$AccountResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountResponse _$AccountResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['accountId', 'status', 'balanceCents']);
  final val = AccountResponse(
    accountId: $checkedConvert('accountId', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$AccountStatusEnumMap, v),
    ),
    balanceCents: $checkedConvert('balanceCents', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$AccountResponseToJson(AccountResponse instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'balanceCents': instance.balanceCents,
    };

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.blocked: 'blocked',
  AccountStatus.closed: 'closed',
};
