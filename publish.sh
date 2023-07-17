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

echo "Building release..."

if [ `uname` != "Darwin" ]; then
    echo "Mac is required for publishing"
    exit 1
fi

./clean.sh
./build.sh release

echo "Publishing to bin..."

echo "Publishing headers"
cp -r out/Release/include/* bin/include/

echo "Publishing `uname`"
cp out/Release/`uname`/libsqlite3.* bin/`uname`/

androidBuilds=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
for build in ${androidBuilds[@]}; do
    echo "Publishing Android $build"
    mkdir -p bin/android/$build
    cp out/Release/android/$build/libsqlite3.so bin/android/$build/libsqlite3.so
done

cp out/Release/android/sqlite3-release.aar bin/android/sqlite3.aar

if [ `uname` == "Darwin" ]; then
    builds=("arm64" "x86_64")
    for build in ${builds[@]}; do
        echo "Publishing iOS $build"
        mkdir -p bin/ios/$build
        cp out/Release/ios/$build/libsqlite3.dylib bin/ios/$build/libsqlite3.dylib
    done

    cp -r out/Release/ios/sqlite3.xcframework bin/ios/
fi

cd bin
git add *
git commit -m "Update SQLite Binaries"
git push
cd ..
git add bin
git commit -m "Published SQLite Binaries"
git push

