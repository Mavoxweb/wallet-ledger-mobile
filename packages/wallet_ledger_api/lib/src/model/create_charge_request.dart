//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_charge_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateChargeRequest {
  /// Returns a new [CreateChargeRequest] instance.
  CreateChargeRequest({required this.keyId, required this.amountCents});

  @JsonKey(name: r'keyId', required: true, includeIfNull: false)
  final String keyId;

  @JsonKey(name: r'amountCents', required: true, includeIfNull: true)
  final int? amountCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateChargeRequest &&
          other.keyId == keyId &&
          other.amountCents == amountCents;

  @override
  int get hashCode =>
      keyId.hashCode + (amountCents == null ? 0 : amountCents.hashCode);

  factory CreateChargeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChargeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateChargeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
