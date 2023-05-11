#!/usr/bin/env bash

# Usage:
#
# newsample.sh <sample-name>

set -eu

mkdir -p $1
cp add/add.wat $1/"$1".wat
cp add/test.js $1/

echo "Created $1"
