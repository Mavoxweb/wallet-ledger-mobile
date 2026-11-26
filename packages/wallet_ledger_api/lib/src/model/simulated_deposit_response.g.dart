// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulated_deposit_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SimulatedDepositResponseCWProxy {
  SimulatedDepositResponse transactionId(String transactionId);

  SimulatedDepositResponse balanceCents(int balanceCents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SimulatedDepositResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SimulatedDepositResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SimulatedDepositResponse call({String transactionId, int balanceCents});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSimulatedDepositResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSimulatedDepositResponse.copyWith.fieldName(...)`
class _$SimulatedDepositResponseCWProxyImpl
    implements _$SimulatedDepositResponseCWProxy {
  const _$SimulatedDepositResponseCWProxyImpl(this._value);

  final SimulatedDepositResponse _value;

  @override
  SimulatedDepositResponse transactionId(String transactionId) =>
      this(transactionId: transactionId);

  @override
  SimulatedDepositResponse balanceCents(int balanceCents) =>
      this(balanceCents: balanceCents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SimulatedDepositResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SimulatedDepositResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SimulatedDepositResponse call({
    Object? transactionId = const $CopyWithPlaceholder(),
    Object? balanceCents = const $CopyWithPlaceholder(),
  }) {
    return SimulatedDepositResponse(
      transactionId: transactionId == const $CopyWithPlaceholder()
          ? _value.transactionId
          // ignore: cast_nullable_to_non_nullable
          : transactionId as String,
      balanceCents: balanceCents == const $CopyWithPlaceholder()
          ? _value.balanceCents
          // ignore: cast_nullable_to_non_nullable
          : balanceCents as int,
    );
  }
}

extension $SimulatedDepositResponseCopyWith on SimulatedDepositResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSimulatedDepositResponse.copyWith(...)` or like so:`instanceOfSimulatedDepositResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SimulatedDepositResponseCWProxy get copyWith =>
      _$SimulatedDepositResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimulatedDepositResponse _$SimulatedDepositResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SimulatedDepositResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['transactionId', 'balanceCents']);
  final val = SimulatedDepositResponse(
    transactionId: $checkedConvert('transactionId', (v) => v as String),
    balanceCents: $checkedConvert('balanceCents', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SimulatedDepositResponseToJson(
  SimulatedDepositResponse instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'balanceCents': instance.balanceCents,
};
