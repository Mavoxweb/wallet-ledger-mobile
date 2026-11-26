#!/usr/bin/env bash
# Gera o cliente Dart da Wallet Ledger API a partir do contrato publicado na
# release fixada em contract.version. Não edite packages/wallet_ledger_api à mão:
# rode este script de novo.
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < contract.version)"
GENERATOR_VERSION="7.27.0"
WORK=".dart_tool/api-gen"
JAR="$WORK/openapi-generator-cli-$GENERATOR_VERSION.jar"
JAR_URL="https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$GENERATOR_VERSION/openapi-generator-cli-$GENERATOR_VERSION.jar"

mkdir -p "$WORK"

echo "Contrato: $VERSION"
gh release download "$VERSION" -R Mavoxweb/wallet-ledger-api -p openapi.json -O "$WORK/openapi.json" --clobber

if [ ! -f "$JAR" ]; then
  curl -sSfL -o "$JAR" "$JAR_URL"
  expected="$(curl -sSfL "$JAR_URL.sha1" | cut -c1-40)"
  actual="$(sha1sum "$JAR" | cut -c1-40)"
  if [ "$expected" != "$actual" ]; then
    echo "sha1 do gerador não confere" >&2
    rm -f "$JAR"
    exit 1
  fi
fi

rm -rf packages/wallet_ledger_api
java -jar "$JAR" generate \
  -i "$WORK/openapi.json" \
  -g dart-dio \
  -o packages/wallet_ledger_api \
  --additional-properties=pubName=wallet_ledger_api,pubDescription="Cliente gerado da Wallet Ledger API",serializationLibrary=json_serializable,nullableFields=true \
  --skip-validate-spec \
  > "$WORK/generator.log"

# O json_serializable atual gera elementos opcionais em mapas ('k': ?v), sintaxe
# do Dart 3.8+. O pubspec gerado declara 3.5, e aí o código gerado não compila.
sed -i "s/sdk: '>=3.5.0 <4.0.0'/sdk: '>=3.8.0 <4.0.0'/" packages/wallet_ledger_api/pubspec.yaml

# Testes e docs gerados não são usados pelo app.
rm -rf packages/wallet_ledger_api/test packages/wallet_ledger_api/doc packages/wallet_ledger_api/.openapi-generator-ignore

(cd packages/wallet_ledger_api && dart pub get > /dev/null && dart run build_runner build --delete-conflicting-outputs > /dev/null)
dart format packages/wallet_ledger_api > /dev/null

echo "Cliente gerado em packages/wallet_ledger_api"
