#!/bin/bash

cd ./diff_testing

echo "Select corpus by number"
echo "1. fuzz_llex"
echo "2. fuzz_lparse"
echo "3. fuzz_lparse_custom_mutation"
read target_id

target_dir=""
if [ $target_id = "1" ]
then
    target_dir="../corpus/fuzz_llex"
elif [ $target_id = "2" ]
then
    target_dir="../corpus/fuzz_lparse"
elif [ $target_id = "3" ]
then
    target_dir="../corpus/fuzz_lparse_custom_mutation"
else
    echo "Invalid id input"
fi

lua_output_path="./result/lua_out.txt"
luajit_output_path="./result/luajit_out.txt"
gopherlua_output_path="./result/gopher_out.txt"
lua2c_output_path="./result/lua2c_out.txt"

cnt=$(ls $target_dir | wc -l)
echo $cnt files

rm -rf ./result
mkdir result

echo "" > $lua_output_path
echo "" > $luajit_output_path
echo "" > $gopherlua_output_path
echo "" > $lua2c_output_path
for filename in $target_dir/* ; do
    result=$(echo "$filename")
    stripname=$(basename -- "$filename")

    lua $filename
    result=$?
    sudo echo "$stripname, $result" >> $lua_output_path

    luajit -b $filename ./tmp/luajit.out
    result=$?
    sudo echo "$stripname, $result" >> $luajit_output_path

    env GOPHER_TARGET=$filename go run ./tgt/run_lua.go
    result=$?
    sudo echo "$stripname, $result" >> $gopherlua_output_path

    lua ./tgt/lua2c/lua2c.lua -c $filename
    result=$?
    sudo echo "$stripname, $result" >> $lua2c_output_path

    #stdout=$( ./itersample.sh )
    #result=$( (echo $stdout | grep -Eq  ^.*success.*$) && echo 0 || echo 1 )

    # stat -c '%y' $filename
done
