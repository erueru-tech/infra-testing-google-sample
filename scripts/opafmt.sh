#!/usr/bin/env bash

set -eu

[[ -z ${CI:-} ]] && OPT="-w" || OPT="--fail --list"
opa fmt $OPT policies/
