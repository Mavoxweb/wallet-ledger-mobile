//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'charge_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChargeResponse {
  /// Returns a new [ChargeResponse] instance.
  ChargeResponse({required this.payload});

  @JsonKey(name: r'payload', required: true, includeIfNull: false)
  final String payload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChargeResponse && other.payload == payload;

  @override
  int get hashCode => payload.hashCode;

  factory ChargeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChargeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChargeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
