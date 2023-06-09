#!/bin/bash

rm -rf build.fuzz
mkdir build.fuzz && cd build.fuzz
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cd ..
