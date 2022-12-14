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

include(${CMAKE_CURRENT_LIST_DIR}/ios-toolchain.cmake)

execute_process(COMMAND xcrun -sdk iphoneos --show-sdk-path OUTPUT_VARIABLE CMAKE_SYSROOT OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
set(CMAKE_OSX_SYSROOT ${CMAKE_SYSROOT})

set(CMAKE_C_FLAGS "-isysroot ${CMAKE_SYSROOT} -arch arm64")
set(CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS})
set(BUILD_TARGET "arm64")
