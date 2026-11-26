//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'simulated_deposit_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SimulatedDepositRequest {
  /// Returns a new [SimulatedDepositRequest] instance.
  SimulatedDepositRequest({required this.amountCents});

  @JsonKey(name: r'amountCents', required: true, includeIfNull: false)
  final int amountCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulatedDepositRequest && other.amountCents == amountCents;

  @override
  int get hashCode => amountCents.hashCode;

  factory SimulatedDepositRequest.fromJson(Map<String, dynamic> json) =>
      _$SimulatedDepositRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SimulatedDepositRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
