#!/bin/bash

cnt=$(ls ./fuzz_llex | wc -l)
echo $cnt files

echo "" > out.txt
for filename in ./result/fuzz_llex_0610_001/* ; do
    # result=$(echo "$filename")

    # ./itersample.sh
    # lua $filename
    # luajit -b $filename luajit.out
    # env GOPHER_TARGET=$filename GOPATH="/home/hsy6119/go" go run run_lua.go
    ./lua2c/clua -c $filename
    result=$?

    # stdout=$( ./itersample.sh )
    # result=$( (echo $stdout | grep -Eq  ^.*success.*$) && echo 0 || echo 1 )

    sudo echo $result >> out.txt

    # stat -c '%y' $filename
done
