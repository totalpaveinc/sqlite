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

cmake_minimum_required(VERSION 3.22)

project(
    sqlite3 LANGUAGES C CXX
    VERSION 3.39.2
)

message("CFLAGS ${CMAKE_CXX_FLAGS}")

if ("${CMAKE_BUILD_TYPE}" STREQUAL "") 
    SET(CMAKE_BUILD_TYPE "Debug")
endif()

if (
    (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release") AND
    (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
)
    message(FATAL_ERROR "Invalid build type \"${CMAKE_BUILD_TYPE}\"")
endif()

if (PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not allowed")
endif()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")
endif()

add_library(sqlite-intermediate STATIC
    ./src/sqlite/sqlite3.c
    ./src/sqlite/sqlite3.h
    ./src/sqlite/sqlite3ext.h
)

add_library(sqlite3 SHARED
    ./src/totalpave/jni.cc
    ./src/totalpave/utilities.cpp
    ./src/totalpave/include/tp/sqlite/utilities.h
    ./src/totalpave/include/tp/sqlite/extensions/ConvertISO8601ToTimestamp.h
    ./src/totalpave/extensions/ConvertISO8601ToTimestamp.cpp
)
target_link_libraries(sqlite3
    PUBLIC sqlite-intermediate
    "-Wl"
)
target_include_directories(sqlite3
    PUBLIC ${CMAKE_SOURCE_DIR}/src/sqlite
    PUBLIC ${CMAKE_SOURCE_DIR}/src/totalpave/include
)

# There is a PRE_BUILD... but for all generators other than Visual Studio
# PRE_BUILD fires just before PRE_LINK... effectively making it
# a POST_BUILD
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/sqlite/sqlite3.h ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/include/sqlite3.h
    COMMENT "Installing sqlite3.h"
)
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/sqlite/sqlite3ext.h ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/include/sqlite3ext.h
    COMMENT "Installing sqlite3ext.h"
)
add_custom_command(TARGET sqlite-intermediate POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_SOURCE_DIR}/src/totalpave/include/tp/sqlite/utilities.h ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/include/tp/sqlite/utilities.h
    COMMENT "Installing tp/sqlite/utilities.h"
)

add_custom_command(TARGET sqlite3 POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy
    ${CMAKE_BINARY_DIR}/libsqlite3.${LIB_EXT} ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/${OUT_PLATFORM}/${OUT_ARCH}/libsqlite3.${LIB_EXT}
    COMMENT "Installing ${BUILD_PLATFORM}/${OUT_NAME} libsqlite3.${LIB_EXT}"
)

# Local Tests
if (${INSTALL_TEST})
    add_executable(test ./test/local/main.cpp)
    target_link_libraries(test
        PUBLIC sqlite3
        "-Wl"
    )
    add_custom_command(TARGET test POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy
        ${CMAKE_BINARY_DIR}/test ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/${OUT_PLATFORM}/${OUT_ARCH}/test
        COMMENT "Installing test program"
    )
endif()
