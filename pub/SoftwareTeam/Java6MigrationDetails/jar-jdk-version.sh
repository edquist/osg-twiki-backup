#!/bin/bash

usage () {
  echo "$(basename "$0") jarfile.jar"
  exit
}

[[ -f $1 && $1 = *.jar ]] || usage

unzip -qc "$1" META-INF/MANIFEST.MF  | grep Created-By:

