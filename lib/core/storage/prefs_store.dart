import 'package:shared_preferences/shared_preferences.dart';

/// Preferências simples do aparelho (não sensíveis).
abstract interface class PrefsStore {
  Future<bool> balanceHidden();
  Future<void> setBalanceHidden({required bool hidden});
}

class SharedPrefsStore implements PrefsStore {
  static const _balanceHiddenKey = 'home.balance_hidden';

  @override
  Future<bool> balanceHidden() async =>
      (await SharedPreferences.getInstance()).getBool(_balanceHiddenKey) ??
      false;

  @override
  Future<void> setBalanceHidden({required bool hidden}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_balanceHiddenKey, hidden);
  }
}

class InMemoryPrefsStore implements PrefsStore {
  bool _hidden = false;

  @override
  Future<bool> balanceHidden() async => _hidden;

  @override
  Future<void> setBalanceHidden({required bool hidden}) async =>
      _hidden = hidden;
}
