import 'package:equatable/equatable.dart';

enum PixKeyKind { email, phone, evp }

class PixKeyItem extends Equatable {
  const new({required this.id, required this.kind, required this.value});

  final String id;
  final PixKeyKind kind;
  final String value;

  String get label => switch (kind) {
    PixKeyKind.email => value,
    PixKeyKind.phone => value,
    PixKeyKind.evp => 'aleatória',
  };

  @override
  List<Object?> get props => [id, kind, value];
}
