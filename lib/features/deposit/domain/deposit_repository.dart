/// Depósito simulado (só existe na demonstração): põe dinheiro fictício na
/// conta para testar o Pix.
abstract interface class DepositRepository {
  /// Devolve o saldo depois do depósito.
  Future<int> simulated({
    required int amountCents,
    required String idempotencyKey,
  });
}
