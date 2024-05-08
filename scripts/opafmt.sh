#!/bin/bash

set -eu

[[ -z ${CI:-} ]] && OPT="-w" || OPT="--fail --list"
opa fmt --v1-compatible --rego-v1 $OPT policies/
