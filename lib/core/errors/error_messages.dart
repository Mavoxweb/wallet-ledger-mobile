import 'package:wallet_ledger_mobile/core/errors/failure.dart';

/// Texto para a pessoa, a partir do código estável da API.
///
/// Regra de escrita: o que aconteceu + o que fazer agora, em linguagem simples,
/// sem culpar quem está usando e sem termos técnicos.
const _byCode = <String, String>{
  'invalid_credentials': 'E-mail ou senha incorretos. Confira e tente de novo.',
  'invalid_refresh_token': 'Sua sessão expirou. Entre de novo para continuar.',
  'email_taken':
      'Este e-mail já tem uma conta. Entre com ele ou use outro e-mail.',
  'cpf_taken': 'Este CPF já tem uma conta. Entre com o e-mail cadastrado.',
  'insufficient_funds':
      'Saldo insuficiente para este Pix. Confira o valor e tente de novo.',
  'account_not_active':
      'Esta conta está bloqueada e não pode fazer ou receber Pix agora.',
  'self_transfer':
      'Essa chave é sua. Para enviar um Pix, use a chave de outra pessoa.',
  'not_found':
      'Não encontramos essa chave Pix. Confira se ela foi digitada certinho.',
  'invalid_pix_key':
      'Essa chave Pix não é válida. Confira o formato e tente de novo.',
  'pix_key_taken': 'Essa chave Pix já está cadastrada em uma conta.',
  'pix_key_limit':
      'Você já tem 5 chaves Pix, o máximo permitido. '
      'Remova uma para cadastrar outra.',
  'deposit_limit':
      r'O depósito simulado aceita até R$ 1.000,00 por vez '
      r'e R$ 5.000,00 por dia.',
  'idempotency_key_reused':
      'Esse pedido mudou durante o envio. Volte e confira os dados.',
};

const _network =
    'Sem conexão com o servidor. Verifique sua internet e tente de novo.';
const _invalidData =
    'Alguns dados não estão certos. Confira os campos destacados.';
const _unexpected =
    'Algo deu errado do nosso lado. Tente de novo em instantes.';

String messageFor(Failure failure) => switch (failure) {
  ApiFailure(:final code) => _byCode[code] ?? _unexpected,
  ValidationFailure() => _invalidData,
  NetworkFailure() => _network,
};
