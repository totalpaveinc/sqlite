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

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

set(NDK_VERSION "25.0.8775105")
set(ANDROID_VERSION 24)

set(CMAKE_ANDROID_STL_TYPE "c++_shared")

set(ANDROID_TOOLCHAIN_ROOT "$ENV{ANDROID_HOME}/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/${BUILD_HOST}-${CMAKE_HOST_SYSTEM_PROCESSOR}")
set(CMAKE_SYSROOT "${ANDROID_TOOLCHAIN_ROOT}/sysroot")
set(CMAKE_AR "${ANDROID_TOOLCHAIN_ROOT}/bin/llvm-ar")
set(CMAKE_RANLIB "${ANDROID_TOOLCHAIN_ROOT}/bin/llvm-ranlib")

if (NOT EXISTS ${CMAKE_SYSROOT})
    message(FATAL_ERROR "${CMAKE_SYSROOT} does not exists.")
endif()

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(BUILD_PLATFORM "android")

add_compile_definitions("ANDROID")
