#!/bin/bash

rm -rf build.fuzz
mkdir build.fuzz && cd build.fuzz
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cd ..

cp -r metalua.setup/metalua build.fuzz/metalua
cp metalua.setup/metalua.lua build.fuzz/metalua.lua
cp metalua.setup/checks.lua build.fuzz/checks.lua

./clear_corpus.sh
