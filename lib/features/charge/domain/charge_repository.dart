abstract interface class ChargeRepository {
  Future<String> create({required String keyId, int? amountCents});
}
