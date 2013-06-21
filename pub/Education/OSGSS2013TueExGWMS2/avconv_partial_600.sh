#!/bin/bash
first=-1
for ((i=0; $i<600; i++)); do
  fname=`printf "TreeAni%03d.png" $i`
  if [ -f "$fname" ]; then
   first=$i
   break
  fi
done

if [ "$first" -lt 0 ]; then 
  echo "Cannot find any frames... aborting"
  exit 1
fi

mkdir avwork
if [ $? -ne 0 ]; then
  echo "Failed to create work dir... aborting"
  exit 2
fi

cnt=0

# link all frames before the first to the first one
for ((i=0; $i<$first; i++)); do
  tname=`printf "TreeAni%03d.png" $i`
  ln $fname avwork/$tname
done

# all the following go to the prev one
for ((i=$first; $i<600; i++)); do
  tname=`printf "TreeAni%03d.png" $i`
  if [ -f "$tname" ]; then
    let cnt++
    fname=$tname
  fi
  ln $fname avwork/$tname
done

let mis=600-$cnt
echo "Found $cnt frames, had to fake $mis"
echo

/share/video1/avconv/avconv -r 20 -i avwork/TreeAni%03d.png -codec ffv1 -r 20 TreeAni_hi.avi
rc=$?

#cleanup
rm -fr avwork

exit $rc

