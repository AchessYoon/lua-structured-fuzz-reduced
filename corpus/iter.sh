#!/bin/bash

target_dir="./fuzz_lparse_result"

lua_output_path="./result/lua_out.txt"
luajit_output_path="./result/luajit_out.txt"
gopherlua_output_path="./result/gopher_out.txt"
lua2c_output_path="./result/lua2c_out.txt"

cnt=$(ls $target_dir | wc -l)
echo $cnt files

rm -rf ./result
mkdir result

# echo "" > $lua_output_path
# echo "" > $luajit_output_path
# echo "" > $gopherlua_output_path
echo "" > $lua2c_output_path
for filename in $target_dir/* ; do
    result=$(echo "$filename")

    # lua $filename
    # result=$?
    # sudo echo "$filename, $result" >> $lua_output_path

    # luajit -b $filename luajit.out
    # result=$?
    # sudo echo "$filename, $result" >> $luajit_output_path

    # env GOPHER_TARGET=$filename go run run_lua.go
    # result=$?
    # sudo echo "$filename, $result" >> $gopherlua_output_path
    
    lua ./lua2c/lua2c.lua -c $filename
    result=$?
    sudo echo $result >> $lua2c_output_path

    #stdout=$( ./itersample.sh )
    #result=$( (echo $stdout | grep -Eq  ^.*success.*$) && echo 0 || echo 1 )


    # stat -c '%y' $filename
done
