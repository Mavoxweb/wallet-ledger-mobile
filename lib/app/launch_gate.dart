import 'package:material_ui/material_ui.dart';

/// Segura o app na entrada até a animação e a biometria terminarem.
class LaunchGate extends ChangeNotifier {
  bool _ready = false;

  bool get ready => _ready;

  void open() {
    if (_ready) return;
    _ready = true;
    notifyListeners();
  }
}

/// Só o comando de liberar, sem poder ouvir: o `provider` não entrega um
/// `ChangeNotifier` por um provedor comum.
class LaunchOpener {
  const new(this.open);

  final VoidCallback open;
}
