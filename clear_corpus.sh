#!/bin/bash

rm -r corpus/fuzz_llex
mkdir corpus/fuzz_llex
cp ./initial_seed.lua corpus/fuzz_llex/1

rm -r corpus/fuzz_lparse
mkdir corpus/fuzz_lparse
cp ./initial_seed.lua corpus/fuzz_lparse/1

rm -r corpus/fuzz_lparse_custom_mutation
mkdir corpus/fuzz_lparse_custom_mutation
cp ./initial_seed.lua corpus/fuzz_lparse_custom_mutation/1

rm -r corpus/fuzz_filter
mkdir corpus/fuzz_filter
# touch corpus/fuzz_llex/1
# chmod 775 corpus/fuzz_llex/1
