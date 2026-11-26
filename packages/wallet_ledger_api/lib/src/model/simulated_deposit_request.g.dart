// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulated_deposit_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SimulatedDepositRequestCWProxy {
  SimulatedDepositRequest amountCents(int amountCents);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SimulatedDepositRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SimulatedDepositRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SimulatedDepositRequest call({int amountCents});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSimulatedDepositRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSimulatedDepositRequest.copyWith.fieldName(...)`
class _$SimulatedDepositRequestCWProxyImpl
    implements _$SimulatedDepositRequestCWProxy {
  const _$SimulatedDepositRequestCWProxyImpl(this._value);

  final SimulatedDepositRequest _value;

  @override
  SimulatedDepositRequest amountCents(int amountCents) =>
      this(amountCents: amountCents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SimulatedDepositRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SimulatedDepositRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SimulatedDepositRequest call({
    Object? amountCents = const $CopyWithPlaceholder(),
  }) {
    return SimulatedDepositRequest(
      amountCents: amountCents == const $CopyWithPlaceholder()
          ? _value.amountCents
          // ignore: cast_nullable_to_non_nullable
          : amountCents as int,
    );
  }
}

extension $SimulatedDepositRequestCopyWith on SimulatedDepositRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSimulatedDepositRequest.copyWith(...)` or like so:`instanceOfSimulatedDepositRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SimulatedDepositRequestCWProxy get copyWith =>
      _$SimulatedDepositRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimulatedDepositRequest _$SimulatedDepositRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SimulatedDepositRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['amountCents']);
  final val = SimulatedDepositRequest(
    amountCents: $checkedConvert('amountCents', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$SimulatedDepositRequestToJson(
  SimulatedDepositRequest instance,
) => <String, dynamic>{'amountCents': instance.amountCents};
