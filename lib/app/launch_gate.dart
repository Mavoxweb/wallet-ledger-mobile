import 'package:material_ui/material_ui.dart';

/// Segura o app na tela de entrada até ela terminar o trabalho dela:
/// a animação e, se houver sessão, o desbloqueio por biometria.
///
/// `ChangeNotifier` avisa quem estiver ouvindo (o roteador) quando muda.
class LaunchGate extends ChangeNotifier {
  bool _ready = false;

  bool get ready => _ready;

  void open() {
    if (_ready) return;
    _ready = true;
    notifyListeners();
  }
}

/// O que a tela de entrada recebe: só o comando de liberar o app, sem poder
/// ouvir o portão. (O `provider` recusa entregar um `ChangeNotifier` por um
/// provedor comum, porque as telas não seriam avisadas das mudanças.)
class LaunchOpener {
  const new(this.open);

  final VoidCallback open;
}
