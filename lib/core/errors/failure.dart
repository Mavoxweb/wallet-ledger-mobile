/// Tudo o que pode dar errado ao falar com a API, já traduzido do HTTP.
sealed class Failure implements Exception {
  const new();
}

/// Regra de negócio ou erro da API, com o `code` estável do ProblemDetails
/// (por exemplo `insufficient_funds`). O app decide a mensagem pelo código.
final class ApiFailure extends Failure {
  const new({required this.code, required this.message, required this.status});

  final String code;
  final String message;
  final int status;
}

/// Dados de entrada recusados (`400`), com os erros por campo.
final class ValidationFailure extends Failure {
  const new(this.errors);

  final Map<String, List<String>> errors;
}

/// Sem conexão ou servidor fora do ar.
final class NetworkFailure extends Failure {
  const new();
}
