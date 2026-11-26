/// Configuração de ambiente, lida na compilação:
/// `flutter run --dart-define=API_BASE_URL=https://…`.
class Env {
  const new({required this.apiBaseUrl});

  /// `String.fromEnvironment` só funciona com `const`: o valor é fixado no
  /// build, não lido em tempo de execução.
  factory fromDefines() => const Env(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    ),
  );

  final String apiBaseUrl;
}
