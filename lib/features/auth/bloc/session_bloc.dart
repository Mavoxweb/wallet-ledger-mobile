import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

sealed class SessionEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// O app abriu: existe sessão guardada?
final class SessionStarted extends SessionEvent {
  const new();
}

/// Login ou cadastro concluídos (os tokens já foram guardados).
final class SessionLoggedIn extends SessionEvent {
  const new();
}

/// A pessoa tocou em "Sair".
final class SessionLoggedOut extends SessionEvent {
  const new();
}

/// O interceptor não conseguiu renovar o token.
final class SessionExpired extends SessionEvent {
  const new();
}

sealed class SessionState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Ainda verificando (durante a animação de entrada).
final class SessionUnknown extends SessionState {
  const new();
}

final class SessionAuthenticated extends SessionState {
  const new(this.me);

  final Me me;

  @override
  List<Object?> get props => [me];
}

final class SessionUnauthenticated extends SessionState {
  const new();
}

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  new(this._repository) : super(const SessionUnknown()) {
    on<SessionStarted>(_onStarted);
    on<SessionLoggedIn>(_onLoggedIn);
    on<SessionLoggedOut>(_onLoggedOut);
    on<SessionExpired>(_onExpired);
  }

  final AuthRepository _repository;

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    if (!await _repository.hasSession()) {
      return emit(const SessionUnauthenticated());
    }
    await _loadProfile(emit);
  }

  Future<void> _onLoggedIn(SessionLoggedIn event, Emitter<SessionState> emit) =>
      _loadProfile(emit);

  Future<void> _onLoggedOut(
    SessionLoggedOut event,
    Emitter<SessionState> emit,
  ) async {
    await _repository.logout();
    emit(const SessionUnauthenticated());
  }

  Future<void> _onExpired(
    SessionExpired event,
    Emitter<SessionState> emit,
  ) async {
    await _repository.clearSession();
    emit(const SessionUnauthenticated());
  }

  Future<void> _loadProfile(Emitter<SessionState> emit) async {
    try {
      emit(SessionAuthenticated(await _repository.me()));
    } on Failure {
      // Sessão guardada que não vale mais: começa do zero, no login.
      await _repository.clearSession();
      emit(const SessionUnauthenticated());
    }
  }
}
