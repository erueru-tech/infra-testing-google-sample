#!/bin/bash

set -eu

readonly SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
readonly ROOT_DIR=$(cd $SCRIPTS_DIR && cd .. && pwd)

(cd $ROOT_DIR/terraform tflint --init)
TFLINT_CONFIG_FILE=$ROOT_DIR/terraform/.tflint.hcl tflint --recursive
