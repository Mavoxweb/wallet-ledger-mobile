import 'dart:async';

/// Avisa Início e Extrato que o saldo mudou (por exemplo, depois de um Pix).
class AccountEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void changed() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
