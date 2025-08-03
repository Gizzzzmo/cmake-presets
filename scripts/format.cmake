#!/usr/bin/env -S cmake -P

execute_process(
    COMMAND git ls-files
    OUTPUT_VARIABLE files
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR ${files})
endif()

string(REPLACE "\n" ";" files ${files})

message("${CMAKE_ARGV3} -i <git-tracked source files>")
foreach(file ${files})
    if(file MATCHES "\\.(c|h|cpp|hpp|cc|hh)\$")
        execute_process(COMMAND ${CMAKE_ARGV3} -i ${file})
    endif()
endforeach()
