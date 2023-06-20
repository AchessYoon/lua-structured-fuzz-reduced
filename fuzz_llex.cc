#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "llex_helper.h"
using namespace std;

#ifndef FUZZ_ENTRY
#define FUZZ_ENTRY LLVMFuzzerTestOneInput
#endif

bool LIMIT_ITER = true;
int MAX_ITER = 10;
int iter_cnt = 0;

extern "C" int FUZZ_ENTRY(const uint8_t *data, size_t size)
{
	if(LIMIT_ITER) assert(iter_cnt<MAX_ITER); iter_cnt ++;
    llex_fuzz(data, size);
    return 0;
}
