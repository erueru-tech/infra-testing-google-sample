#!/bin/bash

set -eu

readonly SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
readonly ROOT_DIR=$(cd $SCRIPTS_DIR && cd .. && pwd)

# TFLint v0.50以降、シンボリックリンクを含むフォルダ構造で-recursiveオプションを使用するとパス解決エラーが発生するようになった
# そのためHCLファイルを持つ各ディレクトリでtflintコマンドを実行するように変更したが、さらにこれまで要求されなかった必須の変数まで要求するようになったので
# 以下のように環境変数経由で適当な値を渡している
export TF_VAR_service=infra-testing-google-sample
export TF_VAR_env=test

# install plugins
# CI環境ではキャッシュする必要があることからワークフロー側で実行するようにしている
if [[ -z ${CI:-} ]]; then
  (cd $ROOT_DIR/terraform && tflint --init)
fi

# environments
while IFS= read ENV_DIR; do
  for TIER in "tier1" "tier2"; do
    echo "run tflint in $ENV_DIR/$TIER"
    (cd $ENV_DIR/$TIER && TFLINT_CONFIG_FILE=$ROOT_DIR/terraform/.tflint.hcl tflint)
  done
done <<< "$(find terraform/environments -type d -mindepth 1 -maxdepth 1 | grep -v scripts)"

# modules
while IFS= read MODULE_DIR; do
  echo "run tflint in $MODULE_DIR"
  (cd $MODULE_DIR && TFLINT_CONFIG_FILE=$ROOT_DIR/terraform/.tflint.hcl tflint)
done <<< "$(find terraform/modules -type d -mindepth 1 -maxdepth 1 | grep -v scripts)"
