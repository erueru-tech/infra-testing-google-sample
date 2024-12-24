#!/usr/bin/env bash

set -eu

TEST_MATRIX_MODULES=$(yq .*.[] .github/data/test_matrix.yaml | sort)
MODULE_DIRS=$(ls -1 terraform/modules/ | grep -v scripts | sort)
echo "----- TEST_MATRIX_MODULES -----"
echo "$TEST_MATRIX_MODULES"
echo "-----     MODULE_DIRS     -----"
echo "$MODULE_DIRS"

if [[ "$TEST_MATRIX_MODULES" != "$MODULE_DIRS" ]]; then
  echo "The modules defined in test_matrix.yaml don't match those in the directory."
  exit 1
fi
