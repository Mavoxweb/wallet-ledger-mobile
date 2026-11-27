import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/register.dart';

enum RegisterStatus { editing, submitting, success, failure }

class RegisterState extends Equatable {
  const new({
    this.name = '',
    this.cpf = '',
    this.email = '',
    this.password = '',
    this.status = RegisterStatus.editing,
    this.failure,
  });

  final String name;
  final String cpf;
  final String email;
  final String password;
  final RegisterStatus status;
  final Failure? failure;

  bool get canSubmit =>
      name.trim().isNotEmpty &&
      cpf.isNotEmpty &&
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      status != RegisterStatus.submitting;

  /// Primeira mensagem de erro da API para um campo (validação do servidor).
  String? fieldError(String field) => switch (failure) {
    ValidationFailure(:final errors) => errors[field]?.first,
    _ => null,
  };

  RegisterState copyWith({
    String? name,
    String? cpf,
    String? email,
    String? password,
    RegisterStatus? status,
    Failure? failure,
  }) => RegisterState(
    name: name ?? this.name,
    cpf: cpf ?? this.cpf,
    email: email ?? this.email,
    password: password ?? this.password,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [name, cpf, email, password, status, failure];
}

class RegisterCubit extends Cubit<RegisterState> {
  new(this._register) : super(const RegisterState());

  final Register _register;

  void nameChanged(String v) =>
      emit(state.copyWith(name: v, status: RegisterStatus.editing));
  void cpfChanged(String v) =>
      emit(state.copyWith(cpf: v, status: RegisterStatus.editing));
  void emailChanged(String v) =>
      emit(state.copyWith(email: v, status: RegisterStatus.editing));
  void passwordChanged(String v) =>
      emit(state.copyWith(password: v, status: RegisterStatus.editing));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: RegisterStatus.submitting));
    try {
      await _register(
        name: state.name,
        cpf: state.cpf,
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } on Failure catch (failure) {
      emit(state.copyWith(status: RegisterStatus.failure, failure: failure));
    }
  }
}
