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

source build-tools/public/assertions.sh
source build-tools/public/DirectoryTools.sh

assertMac
assertGitRepo
assertCleanRepo

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Version is required."
    exit 2
fi

echo $VERSION > VERSION

./clean.sh
./build.sh release

git add VERSION
assertLastCall
git commit -m "Release: $VERSION"
assertLastCall
git tag -a "v$VERSION" -m "Release: $VERSION"
assertLastCall
git push
git push --tags
assertLastCall

spushd android
    ./gradlew :sqlite3:publishReleasePublicationToMavenRepository
spopd

spushd dist/cordova
    npm publish cordova-plugin-libsqlite.tgz
    assertLastCall
spopd

gh release create v$VERSION \
    ./dist/ios/sqlite.xcframework.zip \
    ./dist/android/sqlite3.aar \
    ./dist/cordova/cordova-plugin-libsqlite.tgz \
    ./dist/sqlite3-dev.zip \
    ./dist/sqlite3-dev.zip.sha1.txt \
    ./dist/android/sqlite3.aar.sha1.txt \
    ./dist/ios/sqlite.xcframework.zip.sha1.txt \
    --verify-tag --generate-notes

pod spec lint sqlite.podspec
assertLastCall

pod repo push tp-public sqlite.podspec
