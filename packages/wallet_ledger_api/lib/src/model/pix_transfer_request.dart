//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/pix_key_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pix_transfer_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PixTransferRequest {
  /// Returns a new [PixTransferRequest] instance.
  PixTransferRequest({
    required this.keyType,

    required this.keyValue,

    required this.amountCents,

    required this.description,
  });

  @JsonKey(name: r'keyType', required: true, includeIfNull: false)
  final PixKeyType keyType;

  @JsonKey(name: r'keyValue', required: true, includeIfNull: false)
  final String keyValue;

  @JsonKey(name: r'amountCents', required: true, includeIfNull: false)
  final int amountCents;

  @JsonKey(name: r'description', required: true, includeIfNull: true)
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixTransferRequest &&
          other.keyType == keyType &&
          other.keyValue == keyValue &&
          other.amountCents == amountCents &&
          other.description == description;

  @override
  int get hashCode =>
      keyType.hashCode +
      keyValue.hashCode +
      amountCents.hashCode +
      (description == null ? 0 : description.hashCode);

  factory PixTransferRequest.fromJson(Map<String, dynamic> json) =>
      _$PixTransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PixTransferRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
