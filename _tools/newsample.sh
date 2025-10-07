#!/usr/bin/env bash

# Usage:
#
# newsample.sh <sample-name>

set -eu

if [ -d $1 ]; then
    echo "Error: directory '$1' already exists" >&2
    exit 1
fi

mkdir -p $1
cp add/add.wat $1/"$1".wat
cp add/test.js $1/

echo "Created $1"
