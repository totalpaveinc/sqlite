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

echo "Installing to bin..."

echo "Installing headers"
cp -r out/`uname`/include/* bin/include/

echo "Installing `uname`"
cp out/`uname`/lib/libsqlite3.so bin/`uname`/libsqlite3.so

androidBuilds=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
for build in ${androidBuilds[@]}; do
    echo "Installing Android $build"
    mkdir -p bin/android/$build
    cp out/android/$build/lib/libsqlite3.so bin/android/$build/libsqlite3.so
done

cp android/sqlite3/build/outputs/aar/sqlite3-release.aar bin/android/sqlite3.aar

if [ `uname` == "Darwin" ]; then
    builds=("arm64" "x86_64")
    for build in ${builds[@]}; do
        echo "Installing iOS $build"
        mkdir -p bin/ios/$build
        cp out/ios/$build/lib/libsqlite3.dylib bin/ios/$build/libsqlite3.dylib
    done

    cp -r out/ios/sqlite-release.xcframework bin/ios/sqlite-release.xcframework
    cp -r out/ios/sqlite-debug.xcframework bin/ios/sqlite-debug.xcframework
fi

cd bin
git add *
git commit -m "Update SQLite Binaries"
git push
cd ..
