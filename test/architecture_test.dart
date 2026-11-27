import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _pkg = 'package:wallet_ledger_mobile/';

final _import = RegExp("^import '([^']+)'", multiLine: true);

/// O que um arquivo de `domain/` pode importar: Dart, `equatable`, outros
/// arquivos de domínio e as falhas (que também são Dart puro).
bool _allowedInDomain(String uri) =>
    uri.startsWith('dart:') ||
    uri.startsWith('package:equatable/') ||
    RegExp('^${_pkg}features/\\w+/domain/').hasMatch(uri) ||
    uri == '${_pkg}core/errors/failure.dart';

List<String> _importsOf(File file) => [
  for (final m in _import.allMatches(file.readAsStringSync())) m.group(1)!,
];

void main() {
  final domainFiles = Directory('lib/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.replaceAll(r'\', '/').contains('/domain/'))
      .toList();

  test('existe domínio em todas as features com dados', () {
    for (final feature in [
      'account',
      'auth',
      'charge',
      'deposit',
      'keys',
      'pix',
    ]) {
      expect(
        domainFiles.any(
          (f) => f.path.replaceAll(r'\', '/').contains('/$feature/domain/'),
        ),
        isTrue,
        reason: feature,
      );
    }
  });

  test(
    'domain não conhece Flutter, Dio, o cliente gerado, data nem presentation',
    () {
      final violations = [
        for (final file in domainFiles)
          for (final uri in _importsOf(file))
            if (!_allowedInDomain(uri)) '${file.path}: $uri',
      ];
      expect(violations, isEmpty);
    },
  );

  test('as falhas não dependem do Dio', () {
    expect(_importsOf(File('lib/core/errors/failure.dart')), isEmpty);
  });

  test('presentation conhece só o domínio: nem data, nem o cliente gerado', () {
    final presentation = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/presentation/'));
    final violations = [
      for (final file in presentation)
        for (final uri in _importsOf(file))
          if (RegExp('^${_pkg}features/\\w+/data/').hasMatch(uri) ||
              uri.startsWith('package:wallet_ledger_api/') ||
              uri.startsWith('package:dio/'))
            '${file.path}: $uri',
    ];
    expect(violations, isEmpty);
  });

  test('as telas leem casos de uso, nunca repositórios', () {
    final presentation = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/presentation/'));
    final reads = RegExp(r'context\.(read|watch)<\w+Repository>');
    final violations = [
      for (final file in presentation)
        if (reads.hasMatch(file.readAsStringSync())) file.path,
    ];
    expect(violations, isEmpty);
  });
}
