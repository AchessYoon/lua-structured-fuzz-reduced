#!/bin/bash

cnt=$(ls ./fuzz_llex | wc -l)
echo $cnt files

echo "" > out.txt
for filename in ./fuzz_llex/* ; do
    # result=$(echo "$filename")

    # ./itersample.sh
    # lua $filename
    luajit -b $filename luajit.out
    result=$?

    # stdout=$( ./itersample.sh )
    # result=$( (echo $stdout | grep -Eq  ^.*success.*$) && echo 0 || echo 1 )

    sudo echo $result >> out.txt

    # stat -c '%y' $filename
done
