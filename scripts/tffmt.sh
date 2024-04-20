#!/bin/bash

set -eu

# .pre-commit-configのentryにコマンドを直書きすると実行されないのでシェル化
cd terraform
if [[ -z ${CI:-} ]]; then
  terraform fmt -recursive
else
  terraform fmt -recursive -check
fi
