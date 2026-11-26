import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Pede a digital ou o rosto antes de ações sensíveis (abrir o app com sessão
/// salva, confirmar um Pix).
///
/// Sem biometria disponível (web, ou aparelho sem sensor cadastrado),
/// [isAvailable] é falso e [confirm] deixa passar: o app não trava quem não
/// tem como usar a biometria.
class BiometricGate {
  new([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on Object {
      return false;
    }
  }

  Future<bool> confirm(String reason) async {
    if (!await isAvailable()) return true;
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on Object {
      return false;
    }
  }
}
