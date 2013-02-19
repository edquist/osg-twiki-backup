#!/bin/bash
set -e

usage () {
  echo "$(basename "$0") package.rpm"
  exit
}

[[ -f $1 && $1 = *.rpm ]] || usage

tmpd=$(mktemp -d)
trap 'rm -rf "$tmpd"' EXIT

rpm2cpio "$1" | (
  cd "$tmpd"
  cpio -idv --quiet \*.jar 2>&1 | xargs -rn 1 jar-jdk-version
)

