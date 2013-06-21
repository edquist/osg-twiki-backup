#!/bin/bash

env |grep GLIDEIN
uname -a
id


# prepare the env
mkdir work
cd work
mv ../povray.gz .
gunzip povray.gz
chmod u+x povray
tar -xzf ../tree.tgz

case $1 in
 0)
  ops="-SF0 -EF9"
  ;;
 1) 
  ops="-SF10 -EF14"
  ;;
 2) 
  ops="-SF15 -EF19"
  ;;
 3)
  ops="-SF20 -EF23"
  ;;
 4)
  ops="-SF24 -EF27"
  ;;
 5)
  ops="-SF28 -EF29"
  ;;
 *)
  exit 1
esac

./povray -W400 -H300 -KFI0 -KFF29 -KI0.0 -KF20.0 $ops TreeAni.pov

# copy the outputs in the top dir,
# so condor will pick them up
cp *png ../

