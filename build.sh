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

echo "Building SQLite..."
source _init.sh

cd $PROJECT_DIR/src/sqlite

make clean > /dev/null 2>&1 # Hide clean errors, they are probably not important (e.g. indicating that there is nothing to clean on fresh repos)

rm -rf out #clean the out directory and recreate the ABI paths

if [ `uname` == "Darwin" ]; then
    mkdir -p out/ios/arm64
    mkdir -p out/ios/x86_64
fi

# Bash Arrays aren't exportable which means we need to redeclare this in every library...
builds=("local" "android-armeabi-v7a" "android-arm64-v8a" "android-x86" "android-x86_64")
if [ `uname` == "Darwin" ]; then
    builds+=("ios-arm64" "ios-x86_64")
fi

CFLAGS="-fPIC -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_NOHAVE_SYSTEM"

for build in ${builds[@]}; do
    echo "Building SQLite for $build"
    # We do not direct the prefix to the prebuilt directory directly because we don't want any executable binaries or shared documentations
    # in the repo, we **just** need the include and library binaries.
    prefix=$PROJECT_DIR/src/sqlite/out/$build
    mkdir -p $prefix

    buildShared=yes
    buildStatic=no
    buildJNI=no

    if [ "$build" == "local" ]; then
        ./configure \
            CFLAGS="${CFLAGS}" \
            --prefix=$prefix \
            --enable-all \
            --enable-static=$buildStatic \
            --enable-shared=$buildShared \
            --enable-editline=no \
            > /dev/null 2>&1
    else
        case $build in
            android-armeabi-v7a)
                CC="${ANDROID_ARM_CLANG}"
                CXX="${ANDROID_ARM_CLANGXX}"
                host="arm-linux-android"
                buildStatic=yes
                buildShared=no
                buildJNI=yes
                ;;
            android-arm64-v8a)
                CC="${ANDROID_AARCH64_CLANG}"
                CXX="${ANDROID_AARCH64_CLANGXX}"
                host="aarch64-linux-android"
                buildStatic=yes
                buildShared=no
                buildJNI=yes
                ;;
            android-x86)
                CC="${ANDROID_X86_CLANG}"
                CXX="${ANDROID_X86_CLANGXX}"
                host="x86-linux-android"
                buildStatic=yes
                buildShared=no
                buildJNI=yes
                ;;
            android-x86_64)
                CC="${ANDROID_X86_64_CLANG}"
                CXX="${ANDROID_X86_64_CLANGXX}"
                host="x86_64-linux-android"
                buildStatic=yes
                buildShared=no
                buildJNI=yes
                ;;
            # TODO add iOS -- it should be built as a shared, not static
        esac

        ./configure \
            CC="$CC" \
            CFLAGS="${CFLAGS}" \
            --prefix=$prefix \
            --enable-all \
            --enable-static=$buildStatic \
            --enable-shared=$buildShared \
            --enable-editline=no \
            --host=$host \
            > /dev/null 2>&1
    fi

    make -j ${CPUCOUNT} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to make SQLite for $build"
        exit 1
    fi
    make install > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Failed to intermediate install SQLite for $build"
        exit 1
    fi

    if [ "$buildJNI" == "yes" ]; then
        # Build JNI Wrapper
        cd $PROJECT_DIR/src/android
        ${CXX} -shared -fPIC -DANDROID -I$prefix/include -L$prefix/lib -lsqlite3 -o $prefix/lib/libsqlite3.so jni.cc
        cd $PROJECT_DIR/src/sqlite
    fi

    case $build in
        local)
            prebuildPath=$PREBUILT_LOCAL
            ;;
        android-armeabi-v7a)
            prebuildPath=$PREBUILT_ANDROID_ARM32
            ;;
        android-arm64-v8a)
            prebuildPath=$PREBUILT_ANDROID_ARM64
            ;;
        android-x86)
            prebuildPath=$PREBUILT_ANDROID_X86
            ;;
        android-x86_64)
            prebuildPath=$PREBUILT_ANDROID_X86_64
            ;;
        ios-arm64)
            prebuildPath=$PREBUILT_IOS_ARM64
            ;;
        ios-x86_64)
            prebuildPath=$PREBUILT_IOS_X86_64
            ;;
    esac

    mkdir -p $prebuildPath
    mkdir -p $prebuildPath/lib

    cp -r $prefix/include $prebuildPath/
    cp -r $prefix/lib/libsqlite3.so $prebuildPath/lib/libsqlite3.so

    make clean > /dev/null 2>&1
done

cd $PROJECT_DIR

source _buildAAR.sh

if [ `uname` == "Darwin" ]; then
    source _buildXCFramework.sh
fi
