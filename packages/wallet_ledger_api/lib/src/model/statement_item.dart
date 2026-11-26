//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/direction.dart';
import 'package:wallet_ledger_api/src/model/transaction_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'statement_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StatementItem {
  /// Returns a new [StatementItem] instance.
  StatementItem({
    required this.postingId,

    required this.transactionId,

    required this.type,

    required this.direction,

    required this.amountCents,

    required this.counterpartyMaskedName,

    required this.description,

    required this.createdAt,
  });

  @JsonKey(name: r'postingId', required: true, includeIfNull: false)
  final int postingId;

  @JsonKey(name: r'transactionId', required: true, includeIfNull: false)
  final String transactionId;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final TransactionType type;

  @JsonKey(name: r'direction', required: true, includeIfNull: false)
  final Direction direction;

  @JsonKey(name: r'amountCents', required: true, includeIfNull: false)
  final int amountCents;

  @JsonKey(name: r'counterpartyMaskedName', required: true, includeIfNull: true)
  final String? counterpartyMaskedName;

  @JsonKey(name: r'description', required: true, includeIfNull: true)
  final String? description;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatementItem &&
          other.postingId == postingId &&
          other.transactionId == transactionId &&
          other.type == type &&
          other.direction == direction &&
          other.amountCents == amountCents &&
          other.counterpartyMaskedName == counterpartyMaskedName &&
          other.description == description &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      postingId.hashCode +
      transactionId.hashCode +
      type.hashCode +
      direction.hashCode +
      amountCents.hashCode +
      (counterpartyMaskedName == null ? 0 : counterpartyMaskedName.hashCode) +
      (description == null ? 0 : description.hashCode) +
      createdAt.hashCode;

  factory StatementItem.fromJson(Map<String, dynamic> json) =>
      _$StatementItemFromJson(json);

  Map<String, dynamic> toJson() => _$StatementItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
