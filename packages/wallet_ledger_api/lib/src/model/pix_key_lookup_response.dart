//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wallet_ledger_api/src/model/pix_key_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pix_key_lookup_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PixKeyLookupResponse {
  /// Returns a new [PixKeyLookupResponse] instance.
  PixKeyLookupResponse({
    required this.keyType,

    required this.maskedName,

    required this.maskedCpf,
  });

  @JsonKey(name: r'keyType', required: true, includeIfNull: false)
  final PixKeyType keyType;

  @JsonKey(name: r'maskedName', required: true, includeIfNull: false)
  final String maskedName;

  @JsonKey(name: r'maskedCpf', required: true, includeIfNull: false)
  final String maskedCpf;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixKeyLookupResponse &&
          other.keyType == keyType &&
          other.maskedName == maskedName &&
          other.maskedCpf == maskedCpf;

  @override
  int get hashCode =>
      keyType.hashCode + maskedName.hashCode + maskedCpf.hashCode;

  factory PixKeyLookupResponse.fromJson(Map<String, dynamic> json) =>
      _$PixKeyLookupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PixKeyLookupResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
