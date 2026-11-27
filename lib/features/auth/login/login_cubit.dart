import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

enum LoginStatus { editing, submitting, success, failure }

class LoginState extends Equatable {
  const new({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.editing,
    this.failure,
  });

  final String email;
  final String password;
  final LoginStatus status;
  final Failure? failure;

  bool get canSubmit =>
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      status != LoginStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    Failure? failure,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [email, password, status, failure];
}

class LoginCubit extends Cubit<LoginState> {
  new(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, status: LoginStatus.editing));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, status: LoginStatus.editing));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _repository.login(email: state.email, password: state.password);
      emit(state.copyWith(status: LoginStatus.success));
    } on Failure catch (failure) {
      emit(state.copyWith(status: LoginStatus.failure, failure: failure));
    }
  }
}
