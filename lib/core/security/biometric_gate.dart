import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Pede a digital ou o rosto antes de ações sensíveis.
/// Sem biometria (web, aparelho sem sensor), [confirm] deixa passar.
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
