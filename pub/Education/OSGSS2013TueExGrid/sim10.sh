#!/bin/bash
let a1="$1 * 5 - 90"
let a2="$1 * 5 - 85"
#echo $a1 $a2
python sweepsim.py 25 200 $a1 $a2 50000
