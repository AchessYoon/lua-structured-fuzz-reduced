#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <assert.h>
#include <lua.hpp>
// #include <lua5.1/lua.hpp>
using namespace std;

bool LIMIT_ITER = false;
int MAX_ITER = 10;
int iter_cnt = 0;

int is_valid_luaprogram(const char* input, size_t size){
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    int result = luaL_loadstring(L, input);

	if(result == 0){
		lua_close(L);
		return 1;
	}
	else{
		FILE* file = fopen("error.txt", "w");
		fprintf(file, "%s", lua_tostring(L, -1));
		fclose(file);
		lua_close(L);
		return 0;
	}
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
	if(LIMIT_ITER) assert(iter_cnt<MAX_ITER); iter_cnt ++;

	char* input = (char*)malloc(size+1);
	if(input == NULL) return 1;
	memcpy(input, data, size);
	input[size] = '\0';

	int result = is_valid_luaprogram(input, size);

	std::string result_cmd = "echo " + to_string(result) + " >> results.txt";
	system(result_cmd.c_str());

	free(input);
	return result;
}
