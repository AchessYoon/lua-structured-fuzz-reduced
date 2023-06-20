#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

using namespace std;
#include "llex_helper.h"

#ifndef FUZZ_ENTRY
#define FUZZ_ENTRY LLVMFuzzerTestOneInput
#endif

extern "C" int FUZZ_ENTRY(const uint8_t *data, size_t size)
{
    llex_fuzz(data, size);
    return 0;
}

extern "C" size_t
LLVMFuzzerMutate(uint8_t *Data, size_t Size, size_t MaxSize);

extern "C" size_t LLVMFuzzerCustomMutator(uint8_t *Data, size_t Size, size_t MaxSize, unsigned int Seed) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    char* script = "../mutate.lua";

    if (luaL_loadfile(L, script) || lua_pcall(L, 0, 0, 0)) {
        printf("Error running script: %s\n", lua_tostring(L, -1));
        return 1;
    }

    char* code = (char *) malloc(Size+1);
    memcpy(code, Data, Size);
    code[Size] = '\0';

    // Call function Mutate(code, Seed) in lua
    lua_getglobal(L, "Mutate");
    lua_pushstring(L, code);
    lua_pushinteger(L, Seed);

    lua_pcall(L, 2, 1, 0);

    // Return value
    const char* mutant = lua_tostring(L, -1);

    size_t fileSize = strlen(mutant);
    if (fileSize > MaxSize) return Size;

    // std::string fileSize_cmd = "echo " + to_string(fileSize) + " > fileSize.txt";
	// system(fileSize_cmd.c_str());

    memcpy(Data, mutant, fileSize);

    free(code);
    lua_close(L);

    // Add random mutation
    // fileSize = LLVMFuzzerMutate(Data, fileSize, MaxSize);

    return fileSize;
}


// int writeFile(uint8_t *data, size_t dataSize) {
//     FILE *file = fopen("mut_src.lua", "wb");
//     if (file == NULL) return 1;

//     size_t writtenSize = fwrite(data, 1, dataSize, file);
//     if (writtenSize != dataSize) {
//         fclose(file);
//         return 1;
//     }

//     fclose(file);
//     return 0;
// }

// char* readFile(const char *filename, size_t MaxSize) {
//     FILE *file = fopen(filename, "rb");
//     if (file == NULL) {
//         printf("Failed to open file %s\n", filename);
//         fclose(file);
//         return NULL;
//     }

//     // Get the size of the file by seeking to the end
//     fseek(file, 0, SEEK_END);
//     long filesize = ftell(file);
//     fseek(file, 0, SEEK_SET);

//     // Allocate enough memory for the entire file
//     char *buffer = (char*)malloc(filesize + 1);
//     if (buffer == NULL || MaxSize <= filesize) {
//         fclose(file);
//         free(buffer);
//         return NULL;
//     }

//     // Read the file into the buffer
//     size_t readSize = fread(buffer, 1, filesize, file);
//     if (readSize != filesize) {
//         printf("Failed to read file %s\n", filename);
//         fclose(file);
//         free(buffer);
//         return NULL;
//     }

//     fclose(file);
//     buffer[filesize] = '\0'; // Null-terminate the string

//     return buffer;
// }

// extern "C" size_t LLVMFuzzerCustomMutator(uint8_t *Data, size_t Size, size_t MaxSize, unsigned int Seed) {
// 		writeFile(Data, Size);
// 		system("lua ../test.lua");

// 		char* fileData = readFile("mutated_script.lua", MaxSize);
// 		if (fileData == NULL) return Size;

// 		int fileSize = strlen(fileData);
// 		if (fileSize > MaxSize) return Size;

// 		std::string fileSize_cmd = "echo " + to_string(fileSize) + " > fileSize.txt";
// 		system(fileSize_cmd.c_str());

// 		memcpy(Data, fileData, fileSize);
// 		// memcpy(Data, fileData, fileSize + 1); // copy including eof token?
// 		free(fileData);
// 		return fileSize;
// }
