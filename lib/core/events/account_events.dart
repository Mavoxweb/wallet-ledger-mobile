import 'dart:async';

/// Avisa as telas que o saldo e o extrato mudaram (por exemplo, depois de um
/// Pix). Início e Extrato escutam e se atualizam sozinhos.
///
/// Um `Stream` simples em vez de um estado global: quem avisa não precisa
/// saber quem escuta.
class AccountEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void changed() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
