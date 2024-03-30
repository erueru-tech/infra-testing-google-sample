#!/bin/bash

set -eu

readonly SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
readonly ROOT_DIR=$(cd $SCRIPTS_DIR && cd .. && pwd)
readonly TERRAFORM_DIR=$ROOT_DIR/terraform
readonly MODULE_NAME=$1
readonly MODULE_DIR=$TERRAFORM_DIR/modules/$MODULE_NAME

if [[ -d $MODULE_DIR ]]; then
  echo "$MODULE_NAME module already exists"
  exit 1
fi

mkdir -p $MODULE_DIR/tests
echo "create $MODULE_NAME directory"

readonly TOUCH_FILES=(
  "main.tf"
  "variables.tf"
  "outputs.tf"
  "tests/variables.tftest.hcl"
  "tests/main.tftest.hcl"
  "_tfvars.sh"
)
for FILE in "${TOUCH_FILES[@]}"; do
  touch $MODULE_DIR/$FILE
  echo "create $FILE"
done

readonly LINK_TF_FILES=(
  "globals.tf"
  "module-globals.tf"
)
for FILE in "${LINK_TF_FILES[@]}"; do
  ln -s ../../$FILE $MODULE_DIR/$FILE
  echo "link $FILE"
done

readonly LINK_SCRIPT_FILES=(
  "apply_destroy.sh"
  "test.sh"
)
for FILE in "${LINK_SCRIPT_FILES[@]}"; do
  ln -s ../scripts/$FILE $MODULE_DIR/$FILE
  echo "link $FILE"
done
