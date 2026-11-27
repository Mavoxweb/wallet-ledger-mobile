import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens {
  const new({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory fromJson(Map<String, dynamic> json) => Tokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };
}

/// Onde a sessão fica guardada entre aberturas do app.
abstract interface class TokenStore {
  Future<Tokens?> read();
  Future<void> write(Tokens tokens);
  Future<void> clear();
}

/// Guarda os tokens no armazenamento seguro do sistema (Keystore no Android).
/// Na web, o plugin usa o armazenamento do navegador com criptografia: serve
/// para a demo, mas não tem a mesma proteção de um aparelho.
class SecureTokenStore implements TokenStore {
  new([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'wallet_ledger.session';
  final FlutterSecureStorage _storage;

  @override
  Future<Tokens?> read() async {
    final raw = await _storage.read(key: _key);
    return raw == null
        ? null
        : Tokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(Tokens tokens) =>
      _storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Usado nos testes e como fallback.
class InMemoryTokenStore implements TokenStore {
  new([this._tokens]);

  Tokens? _tokens;

  @override
  Future<Tokens?> read() async => _tokens;

  @override
  Future<void> write(Tokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
