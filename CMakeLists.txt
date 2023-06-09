project ( fuzzing-lua C )
cmake_minimum_required ( VERSION 2.8 )
cmake_policy(SET CMP0022 NEW)

include(${CMAKE_CURRENT_LIST_DIR}/deps/lua-5.1.cmake)

add_library( luafuzzhelper src/llex_helper.c )
target_link_libraries( luafuzzhelper PRIVATE liblua )
target_include_directories( luafuzzhelper PUBLIC src )

set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic")

if(NOT FUZZ_ENGINE AND NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
  message(FATAL_ERROR "Fuzzing requires a FUZZ_ENGINE or the Clang compiler")
endif()

set(CMAKE_BUILD_TYPE Debug)
if (NOT COVERAGE AND NOT FUZZ_ENGINE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -fsanitize=address,undefined,fuzzer -fno-sanitize=alignment -fno-omit-frame-pointer")
endif()


enable_language(CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS}")

add_custom_target(fuzz_check_all)

if (FUZZ_ENTRY)
  add_definitions(-DFUZZ_ENTRY=${FUZZ_ENTRY})
endif()

function(add_fuzz name dict corpus)
  add_executable(${name} "${name}.cc")
  target_link_libraries(${name} liblua luafuzzhelper pthread ${FUZZ_ENGINE})
  add_custom_target(${name}_run COMMAND ${CMAKE_COMMAND} -E env "ASAN_OPTIONS=allocator_may_return_null=1" "${CMAKE_CURRENT_BINARY_DIR}/${name}" -timeout=2 -dict="${dict}" "${corpus}" DEPENDS ${name})
  set(${name}_new_corpus "${CMAKE_CURRENT_BINARY_DIR}/corpus/${name}")
  add_custom_target(${name}_minimize
    COMMAND mkdir -p "${${name}_new_corpus}"
    COMMAND ${name} -timeout=2 "${${name}_new_corpus}" "${corpus}" -merge=1
    COMMAND rm -rf "${corpus}"
    COMMAND mv "${${name}_new_corpus}" "${corpus}"
  )
  # for checking that the corpus still runs without exploding
  add_custom_target(${name}_check COMMAND "${CMAKE_CURRENT_BINARY_DIR}/${name}" -timeout=2 "${corpus}/*" DEPENDS ${name})
  add_dependencies(fuzz_check_all ${name}_check)
endfunction()

function(add_fuzz_simple name dict)
  add_fuzz(${name} "${CMAKE_CURRENT_SOURCE_DIR}/dict/${dict}" "${CMAKE_CURRENT_SOURCE_DIR}/corpus/${name}")
endfunction()

add_fuzz_simple(fuzz_llex lua.dict)
