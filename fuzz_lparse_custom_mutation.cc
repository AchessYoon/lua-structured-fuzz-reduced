#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <assert.h>
// #include <lua.hpp>
#include <lua5.1/lua.hpp>
#include "llex_helper.h"
using namespace std;

bool LIMIT_ITER = true;
int MAX_ITER = 10;
int iter_cnt = 0;

extern "C" size_t
LLVMFuzzerMutate(uint8_t *Data, size_t Size, size_t MaxSize);

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

int writeFile(uint8_t *data, size_t dataSize) {
    FILE *file = fopen("mut_src.lua", "wb");
    if (file == NULL) return 1;

    size_t writtenSize = fwrite(data, 1, dataSize, file);
    if (writtenSize != dataSize) {
    		fclose(file);
        return 1;
    }

    fclose(file);
		return 0;
}

char* readFile(const char *filename, size_t MaxSize) {
    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        printf("Failed to open file %s\n", filename);
				fclose(file);
        return NULL;
    }

    // Get the size of the file by seeking to the end
    fseek(file, 0, SEEK_END);
    long filesize = ftell(file);
    fseek(file, 0, SEEK_SET);

    // Allocate enough memory for the entire file
    char *buffer = (char*)malloc(filesize + 1);
    if (buffer == NULL || MaxSize <= filesize) {
				fclose(file);
        free(buffer);
        return NULL;
    }

    // Read the file into the buffer
    size_t readSize = fread(buffer, 1, filesize, file);
    if (readSize != filesize) {
        printf("Failed to read file %s\n", filename);
				fclose(file);
        free(buffer);
        return NULL;
    }

    fclose(file);
    buffer[filesize] = '\0'; // Null-terminate the string

    return buffer;
}

extern "C" size_t LLVMFuzzerCustomMutator(uint8_t *Data, size_t Size, size_t MaxSize, unsigned int Seed) {
		writeFile(Data, Size);
		system("lua ../mutate.lua");

		if (rand()%10 == 1) return LLVMFuzzerMutate(Data, Size, MaxSize);

		char* fileData = readFile("mutated_script.lua", MaxSize);
		if (fileData == NULL) return Size;

		int fileSize = strlen(fileData);
		if (fileSize > MaxSize) return Size;

		std::string fileSize_cmd = "echo " + to_string(fileSize) + " > fileSize.txt";
		system(fileSize_cmd.c_str());

		memcpy(Data, fileData, fileSize);
		// memcpy(Data, fileData, fileSize + 1); // copy including eof token?
		free(fileData);
		return fileSize;
}
