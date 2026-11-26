//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'simulated_deposit_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SimulatedDepositResponse {
  /// Returns a new [SimulatedDepositResponse] instance.
  SimulatedDepositResponse({
    required this.transactionId,

    required this.balanceCents,
  });

  @JsonKey(name: r'transactionId', required: true, includeIfNull: false)
  final String transactionId;

  @JsonKey(name: r'balanceCents', required: true, includeIfNull: false)
  final int balanceCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulatedDepositResponse &&
          other.transactionId == transactionId &&
          other.balanceCents == balanceCents;

  @override
  int get hashCode => transactionId.hashCode + balanceCents.hashCode;

  factory SimulatedDepositResponse.fromJson(Map<String, dynamic> json) =>
      _$SimulatedDepositResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SimulatedDepositResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
