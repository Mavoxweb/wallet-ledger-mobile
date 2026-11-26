//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pix_transfer_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PixTransferResponse {
  /// Returns a new [PixTransferResponse] instance.
  PixTransferResponse({
    required this.transactionId,

    required this.amountCents,

    required this.recipientMaskedName,

    required this.balanceCents,

    required this.createdAt,
  });

  @JsonKey(name: r'transactionId', required: true, includeIfNull: false)
  final String transactionId;

  @JsonKey(name: r'amountCents', required: true, includeIfNull: false)
  final int amountCents;

  @JsonKey(name: r'recipientMaskedName', required: true, includeIfNull: false)
  final String recipientMaskedName;

  @JsonKey(name: r'balanceCents', required: true, includeIfNull: false)
  final int balanceCents;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixTransferResponse &&
          other.transactionId == transactionId &&
          other.amountCents == amountCents &&
          other.recipientMaskedName == recipientMaskedName &&
          other.balanceCents == balanceCents &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      transactionId.hashCode +
      amountCents.hashCode +
      recipientMaskedName.hashCode +
      balanceCents.hashCode +
      createdAt.hashCode;

  factory PixTransferResponse.fromJson(Map<String, dynamic> json) =>
      _$PixTransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PixTransferResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
