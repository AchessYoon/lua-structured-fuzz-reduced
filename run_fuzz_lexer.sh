#!/bin/bash

cd  build.fuzz/
date +"%Y-%m-%d %H:%M:%S,%N  %s  %s%3N  %s%N" > ../corpus/timestamp.txt
make fuzz_llex_run
