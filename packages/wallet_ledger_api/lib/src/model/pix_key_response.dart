//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/pix_key_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pix_key_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PixKeyResponse {
  /// Returns a new [PixKeyResponse] instance.
  PixKeyResponse({
    required this.id,

    required this.type,

    required this.value,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final PixKeyType type;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixKeyResponse &&
          other.id == id &&
          other.type == type &&
          other.value == value &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode + type.hashCode + value.hashCode + createdAt.hashCode;

  factory PixKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$PixKeyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PixKeyResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
