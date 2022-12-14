#!/bin/bash

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

buildTargets=("local" "android-armv7a" "android-aarch64" "android-i686" "android-x86_64")
if [ `uname` == "Darwin" ]; then
    buildTargets+=("ios-arm64" "ios-x86_64")
fi

rootDir=`pwd`

if [ `uname` == "Linux" ]; then
    buildHost="linux"
else
    buildHost="mac"
fi

mkdir -p build

for target in ${buildTargets[@]}; do
    
    if [ "$target" == "local" ]; then
        toolchain="local"
    else
        toolchain="$target"
    fi

    cmake \
        -DCMAKE_MODULE_PATH="$rootDir/cmake" \
        -DCMAKE_TOOLCHAIN_FILE=`pwd`/cmake/toolchains/$toolchain.cmake \
        -B build/$target \
        -G"Unix Makefiles" \
        .
    
    cd build/$target
    make
    cd $rootDir
done

source _buildAAR.sh
if [ `uname` == "Darwin" ]; then
    source _buildXCFramework.sh
fi
