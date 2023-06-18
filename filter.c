#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>
#include <stdint.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

size_t read_file(const char* path, char* buf, size_t bufsize)
{
	FILE* f = fopen(path, "rb");
	fseek(f, 0, SEEK_END);
	long size = ftell(f);
	if (size < 0) {
		fclose(f);
		perror("ftell failed when reading file");
		return 0;
	}
	rewind(f);
	if ((size_t)size > bufsize) {
		fclose(f);
		fprintf(stderr, "file '%s' too big (%ld)", path, size);
		return 0;
	}
	size_t bytesRead = fread(buf, 1, size, f);
	fclose(f);
	return bytesRead;
}

int mkdir_recursive(char *path, mode_t mode)
{
	char *last_sep = strrchr(path, '/');
	if (last_sep && last_sep != path)
	{
		// temporarily shorten the path
		*last_sep = 0;
		int result = mkdir_recursive(path, mode);
		*last_sep = '/';
		if (result != 0 && errno != EEXIST)
		{
			return result;
		}
	}
	return mkdir(path, mode);
}

int is_valid_luaprogram(const char* input, size_t size){
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    int result = luaL_loadstring(L, input);
	printf("%d\n",result);
	if(result == 0){
		lua_close(L);
		return 0;
	}
	else{
		lua_close(L);
		return -1;
	}
}

int main(int argc, const char* argv[])
{
	if (argc <= 2) {
		printf("usage: %s input_dir output_dir\n  (no trailing path separators)\n", argv[0]);
		return 0;
	}
	static char buf[1024 * 1024];
	static char pathbuf[512];
	const char* input_dir = argv[1];
	const char* output_dir = argv[2];
	strncpy(pathbuf, output_dir, 512);
	int mkdir_result = mkdir_recursive(pathbuf, 0755);
	if (mkdir_result != 0 && errno != EEXIST) {
		sprintf(pathbuf, "Failed to create output dir \"%s\"", output_dir);
		perror(pathbuf);
		return 1;
	}
	DIR *dir;
	struct dirent *ent;
	if ((dir = opendir (input_dir)) == NULL) {
		sprintf(pathbuf, "Failed to open input dir \"%s\"", input_dir);
		perror(pathbuf);
		return 1;
	}
	while ((ent = readdir (dir)) != NULL) {
		if (ent->d_type == DT_DIR) continue;
		printf("%s\n",ent->d_name);
		sprintf(pathbuf, "%s/%s", input_dir, ent->d_name);
		size_t size = read_file(pathbuf, buf, sizeof(buf));

		sprintf(pathbuf, "%s/%s", output_dir, ent->d_name);

		if(is_valid_luaprogram(buf, sizeof(buf)) == 0){
			FILE* outputFile = fopen(pathbuf, "w");
			fprintf(outputFile,"%s",buf);
			fclose(outputFile);
		}
  	}
  	closedir (dir);
	printf("Results written to: %s\n", output_dir);
	return 0;
}