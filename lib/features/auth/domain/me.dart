import 'package:equatable/equatable.dart';

class Me extends Equatable {
  const new({
    required this.userId,
    required this.name,
    required this.role,
    required this.accountId,
  });

  final String userId;
  final String name;
  final String role;
  final String? accountId;

  String get firstName => name.split(' ').first;

  @override
  List<Object?> get props => [userId, name, role, accountId];
}
