//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum TransactionType {
  @JsonValue(r'deposit')
  deposit(r'deposit'),
  @JsonValue(r'transfer')
  transfer(r'transfer'),
  @JsonValue(r'reversal')
  reversal(r'reversal');

  const TransactionType(this.value);

  final String value;

  @override
  String toString() => value;
}
