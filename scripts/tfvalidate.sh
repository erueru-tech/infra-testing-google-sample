#!/bin/bash

set -eu

# environments
while IFS= read ENV_DIR; do
  for TIER in "tier1" "tier2"; do
    echo "run terraform validate in $ENV_DIR/$TIER"
    (cd $ENV_DIR/$TIER && terraform init -backend=false >/dev/null && terraform validate)
  done
done <<< "$(find terraform/environments -type d -mindepth 1 -maxdepth 1 | grep -v scripts)"

# modules
while IFS= read MODULE_DIR; do
  echo "run terraform validate in $MODULE_DIR"
  (cd $MODULE_DIR && terraform init -backend=false >/dev/null && terraform validate)
done <<< "$(find terraform/modules -type d -mindepth 1 -maxdepth 1 | grep -v scripts)"
