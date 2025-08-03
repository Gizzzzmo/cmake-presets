cmake_minimum_required(VERSION 3.28.0)

option(WARNING_DEFAULT "When on emits a warning that the default preset was used" "OFF")

if(WARNING_DEFAULT)
    message(WARNING "You are using the default profile (./presets/default.p.json) with a preset that likely requires more upfront configuration. The project will possibly not build (or, if it does, possibly not what you expected).")
endif()

project(cmake-profiles)

add_executable(main main.c)

enable_testing()
add_test(NAME main COMMAND ${CMAKE_CURRENT_BINARY_DIR}/main)

if(PROJECT_IS_TOP_LEVEL AND NOT CMAKE_BINARY_DIR STREQUAL ${CMAKE_SOURCE_DIR}/build AND CMAKE_EXPORT_COMPILE_COMMANDS)
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink 
        ${CMAKE_BINARY_DIR}/compile_commands.json 
        ${CMAKE_SOURCE_DIR}/build/compile_commands.json
    )
endif()

