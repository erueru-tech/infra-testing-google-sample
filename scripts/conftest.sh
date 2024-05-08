#!/bin/bash

set -eu

# テストコードを実行したのち、このプロジェクト内で定義しているポリシーを適用
conftest verify --show-builtin-errors
conftest test --all-namespaces .

# 組織ポリシープロジェクトで定義しているポリシーを適用
conftest pull git::https://github.com/erueru-tech/infra-policy-example.git//policy -p org-policies
conftest test -p org-policies --all-namespaces .
