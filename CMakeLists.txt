# Copyright 2022 Total Pave Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

project(
    sqlite3
    LANGUAGES C CXX
)

cmake_minimum_required(VERSION 3.22)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_library(sqlite-intermediate STATIC
    ./src/sqlite/sqlite3.c
    ./src/sqlite/sqlite3.h
    ./src/sqlite/sqlite3ext.h
)

add_library(sqlite3 SHARED
    ./src/totalpave/jni.cc
    ./src/totalpave/utilities.cpp
    ./src/totalpave/utilities.h
)
target_link_libraries(sqlite3
    PUBLIC sqlite-intermediate
    "-Wl"
    "--no-undefined"
)
target_include_directories(sqlite3 PUBLIC ./out/include)
target_compile_options(sqlite3 PUBLIC "-Wall")

# There is a PRE_BUILD... but for all generators other than Visual Studio
# PRE_BUILD fires just before PRE_LINK... effectively making it
# a POST_BUILD
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/sqlite/sqlite3.h ${CMAKE_SOURCE_DIR}/out/include/sqlite3.h
    COMMENT "Installing sqlite3.h"
)
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/sqlite/sqlite3ext.h ${CMAKE_SOURCE_DIR}/out/include/sqlite3ext.h
    COMMENT "Installing sqlite3ext.h"
)
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/totalpave/utilities.h ${CMAKE_SOURCE_DIR}/out/include/tp/sqlite/utilities.h
    COMMENT "Installing tp/sqlite/utilities.h"
)

if ("${BUILD_TARGET}" STREQUAL "local")
    add_custom_command(TARGET sqlite3 POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy
        ${CMAKE_BINARY_DIR}/libsqlite3.so ${CMAKE_SOURCE_DIR}/out/${CMAKE_HOST_SYSTEM_NAME}/libsqlite3.so
        COMMENT "Installing ${BUILD_PLATFORM}/${BUILD_TARGET} libsqlite3.so"
    )
else()
    add_custom_command(TARGET sqlite3 POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy
        ${CMAKE_BINARY_DIR}/libsqlite3.so ${CMAKE_SOURCE_DIR}/out/${BUILD_PLATFORM}/${BUILD_TARGET}/libsqlite3.so
        COMMENT "Installing ${BUILD_PLATFORM}/${BUILD_TARGET} libsqlite3.so"
    )
endif()

# Local Tests
if ("${BUILD_TARGET}" STREQUAL "local")
    add_executable(test ./test/local/main.cpp)
    target_link_libraries(test
        PUBLIC sqlite3
        "-Wl"
        "--no-undefined"
    )
    # target_compile_options(test
    #     PUBLIC "-g"
    #     PUBLIC "-Wall"
    # )
    # target_link_options(test
    #     PUBLIC "-Wl"
    #     PUBLIC "-rdynamic"
    # )
    add_custom_command(TARGET test POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy
        ${CMAKE_BINARY_DIR}/test ${CMAKE_SOURCE_DIR}/out/${CMAKE_HOST_SYSTEM_NAME}/test
        COMMENT "Installing test program"
    )
endif()
