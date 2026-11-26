//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/pix_key_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_pix_key_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreatePixKeyRequest {
  /// Returns a new [CreatePixKeyRequest] instance.
  CreatePixKeyRequest({required this.type, required this.value});

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final PixKeyType type;

  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final String? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePixKeyRequest &&
          other.type == type &&
          other.value == value;

  @override
  int get hashCode => type.hashCode + (value == null ? 0 : value.hashCode);

  factory CreatePixKeyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePixKeyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePixKeyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
