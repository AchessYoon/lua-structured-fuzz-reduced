#!/bin/bash

cnt=$(ls ./fuzz_llex | wc -l)
echo $cnt files

echo "" > info.txt
for filename in ./fuzz_llex/* ; do

    mod_time=$( stat -c '%y' $filename )
    base_name=$( basename $filename )
    result=$( echo $mod_time $base_name )

    sudo echo $result >> info.txt
done
