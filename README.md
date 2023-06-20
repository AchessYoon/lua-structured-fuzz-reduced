Requierment:

    lua5.1
    golang
    gopher

How to run

1. run `./setup.sh`
2. run corresponding command to generate corpus.\
generating input with fuzzing-lua:\
`./run_fuzz_lexer.sh`\
corpus generates in corpus/fuzz_llexer\
generating input with parser as target:\
`./run_fuzz_parser.sh `\
corpus generates in corpus/fuzz_lparser\
generating input with parser as target and structure aware mutation:\
`./run_fuzz_parser_custom_mutation.sh `\
corpus generates in corpus/fuzz_lparser_custom_mutation
3. diff testing
`./run_diff_testing.sh`
You will get 4 result files(lua_out.txt, luajit_out.txt, lua2c_out.txt, gopher_out.txt) in diff_testing/result
4. to clear all corpus, run `./clear_corpus.sh`
