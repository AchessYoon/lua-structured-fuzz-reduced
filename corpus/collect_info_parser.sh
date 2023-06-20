#!/bin/bash

cnt=$(ls ./fuzz_lparse | wc -l)
echo $cnt files

echo "" > info.txt
for filename in ./fuzz_lparse/* ; do

    mod_time=$( stat -c '%y' $filename )
    base_name=$( basename $filename )
    result=$( echo $mod_time , $base_name )

    sudo echo $result >> info.txt
done
