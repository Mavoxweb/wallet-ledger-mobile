//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/account_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountResponse {
  /// Returns a new [AccountResponse] instance.
  AccountResponse({
    required this.accountId,

    required this.status,

    required this.balanceCents,
  });

  @JsonKey(name: r'accountId', required: true, includeIfNull: false)
  final String accountId;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final AccountStatus status;

  @JsonKey(name: r'balanceCents', required: true, includeIfNull: false)
  final int balanceCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountResponse &&
          other.accountId == accountId &&
          other.status == status &&
          other.balanceCents == balanceCents;

  @override
  int get hashCode =>
      accountId.hashCode + status.hashCode + balanceCents.hashCode;

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
