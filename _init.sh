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

export NDK_VERSION="25.0.8775105"
export ANDROID_VERSION="24"

echo "Using Android/NDK $ANDROID_VERSION/$NDK_VERSION"

export BUILD_HOST="`uname | sed 's/./\L&/g'`-`uname -p`"
if [ `uname` == "Linux" ]; then
    export CPUCOUNT=`grep -c 'cpu[0-9]' /proc/stat`
elif [ `uname` == "Darwin" ]; then
    # https://superuser.com/a/161197
    export BUILD_HOST="darwin-x86_64"
    export CPUCOUNT="`sysctl -n hw.ncpu`"
else
    export CPUCOUNT="1"
fi


export ANDROID_TOOLCHAIN_ROOT=${ANDROID_HOME}/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/${BUILD_HOST}
export ANDROID_SYSROOT=${ANDROID_TOOLCHAIN_ROOT}/sysroot

export ANDROID_AARCH64_CLANG="${ANDROID_TOOLCHAIN_ROOT}/bin/aarch64-linux-android${ANDROID_VERSION}-clang"
export ANDROID_ARM_CLANG="${ANDROID_TOOLCHAIN_ROOT}/bin/armv7a-linux-androideabi${ANDROID_VERSION}-clang"
export ANDROID_X86_CLANG="${ANDROID_TOOLCHAIN_ROOT}/bin/i686-linux-android${ANDROID_VERSION}-clang"
export ANDROID_X86_64_CLANG="${ANDROID_TOOLCHAIN_ROOT}/bin/x86_64-linux-android${ANDROID_VERSION}-clang"

export ANDROID_AARCH64_CLANGXX="${ANDROID_AARCH64_CLANG}++ -isysroot=$ANDROID_SYSROOT"
export ANDROID_ARM_CLANGXX="${ANDROID_ARM_CLANG}++ -isysroot=$ANDROID_SYSROOT"
export ANDROID_X86_CLANGXX="${ANDROID_X86_CLANG}++ -isysroot=$ANDROID_SYSROOT"
export ANDROID_X86_64_CLANGXX="${ANDROID_X86_64_CLANG}++ -isysroot=$ANDROID_SYSROOT"

export ANDROID_AARCH64_CLANG="$ANDROID_AARCH64_CLANG -isysroot=$ANDROID_SYSROOT"
export ANDROID_ARM_CLANG="$ANDROID_ARM_CLANG -isysroot=$ANDROID_SYSROOT"
export ANDROID_X86_CLANG="$ANDROID_X86_CLANG -isysroot=$ANDROID_SYSROOT"
export ANDROID_X86_64_CLANG="$ANDROID_X86_64_CLANG -isysroot=$ANDROID_SYSROOT"

#export IOS_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
export IOS_ARM64_SYSROOT=`xcrun -sdk iphoneos --show-sdk-path`
export IOS_X86_64_SYSROOT=`xcrun -sdk iphonesimulator --show-sdk-path`
export IOS_ARM64_CLANG="clang -isysroot $IOS_ARM64_SYSROOT -arch arm64"
export IOS_ARM64_CLANGXX="clang++ -isysroot $IOS_ARM64_SYSROOT -arch arm64"
export IOS_X86_64_CLANG="clang -isysroot $IOS_X86_64_SYSROOT -arch x86_64"
export IOS_X86_64_CLANGXX="clang++ -isysroot $IOS_X86_64_SYSROOT -arch x86_64"
export IOS_DEPLOYMENT_TARGET=12

export PROJECT_DIR=`pwd`
export BUILD_LOG="$PROJECT_DIR/build.log"

# We need to resolve the relative path, which idk if this works on macs
export PREBUILT_DIR="$PROJECT_DIR/out" #`readlink -f ./out`

export PREBUILT_LOCAL=${PREBUILT_DIR}/`uname`
export PREBUILT_ANDROID_ARM64=${PREBUILT_DIR}/android/arm64-v8a
export PREBUILT_ANDROID_ARM32=${PREBUILT_DIR}/android/armeabi-v7a
export PREBUILT_ANDROID_X86=${PREBUILT_DIR}/android/x86
export PREBUILT_ANDROID_X86_64=${PREBUILT_DIR}/android/x86_64

mkdir -p $PREBUILT_LOCAL
mkdir -p $PREBUILT_ANDROID_ARM64
mkdir -p $PREBUILT_ANDROID_ARM32
mkdir -p $PREBUILT_ANDROID_X86
mkdir -p $PREBUILT_ANDROID_X86_64

export ANDROID_LIB_EXTENSION="so"
export IOS_LIB_EXTENSION="dylib"

if [ `uname` == "Darwin" ]; then
    export PREBUILT_IOS_ARM64=${PREBUILT_DIR}/ios/arm64
    export PREBUILT_IOS_X86_64=${PREBUILT_DIR}/ios/x86_64
    mkdir -p $PREBUILT_IOS_ARM64
    mkdir -p $PREBUILT_IOS_X86_64
fi
