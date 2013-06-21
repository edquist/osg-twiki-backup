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


# calculate from both ends, compensate for diff in compute time
# and interlace x10
let pass=$1
let el=$2%30

let f1=$el*10+$pass
let f2=590-$el*10+$pass

./povray -W920 -H690 +A0.1 -KFI0 -KFF599 -KI0.0 -KF20.0 -SF${f1} -EF${f1} TreeAni.pov
./povray -W920 -H690 +A0.1 -KFI0 -KFF599 -KI0.0 -KF20.0 -SF${f2} -EF${f2} TreeAni.pov

# copy the outputs in the top dir,
# so condor will pick them up
cp *png ../

