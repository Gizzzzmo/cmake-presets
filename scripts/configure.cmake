#!/usr/bin/env -S cmake -P

execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    OUTPUT_VARIABLE BRANCH_NAME
    RESULT_VARIABLE result
)
if(result)
    message(FATAL_ERROR ${commit_hash})
endif()
string(REPLACE "\n" "" BRANCH_NAME ${BRANCH_NAME})

execute_process(
    COMMAND git rev-parse HEAD
    OUTPUT_VARIABLE COMMIT_HASH
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR ${commit_hash})
endif()
string(REPLACE "\n" "" COMMIT_HASH ${COMMIT_HASH})

if(BRANCH_NAME STREQUAL HEAD)
    set(BUILD_DIR ${COMMIT_HASH})
else()
    set(BUILD_DIR ${BRANCH_NAME})
endif()

execute_process (
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${BUILD_DIR} build/HEAD
)

configure_file(${CMAKE_ARGV3} ${CMAKE_ARGV4} @ONLY)
