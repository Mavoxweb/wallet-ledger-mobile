import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/config/app_info.dart';

void main() {
  test('a versão do Perfil é a mesma do pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: ([\d.]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(appVersion, version);
  });
}
