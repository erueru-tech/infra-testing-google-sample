#!/bin/bash

set -eu

# テストコードを実行したのち、このプロジェクト内で定義しているポリシーを適用
conftest verify --show-builtin-errors
conftest test --all-namespaces .

# 組織ポリシープロジェクトで定義しているポリシーを適用
# infra-policy-exampleプロジェクトのpolicyディレクトリにはconftest以外にもポリシー用ディレクトリが存在することが想定されるため
# 以下のようにconftestディレクトリ配下のポリシーのみを実行している
conftest pull git::https://github.com/erueru-tech/infra-policy-example.git//policy -p org-policies
conftest test -p org-policies/conftest --all-namespaces .
