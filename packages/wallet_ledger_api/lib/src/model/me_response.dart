//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeResponse {
  /// Returns a new [MeResponse] instance.
  MeResponse({
    required this.userId,

    required this.name,

    required this.role,

    required this.accountId,
  });

  @JsonKey(name: r'userId', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final String role;

  @JsonKey(name: r'accountId', required: true, includeIfNull: true)
  final String? accountId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeResponse &&
          other.userId == userId &&
          other.name == name &&
          other.role == role &&
          other.accountId == accountId;

  @override
  int get hashCode =>
      userId.hashCode +
      name.hashCode +
      role.hashCode +
      (accountId == null ? 0 : accountId.hashCode);

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
