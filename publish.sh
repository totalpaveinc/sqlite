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

# Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not in a Git repository."
    exit 1
fi

if [ `uname` != "Darwin" ]; then
    echo "Mac is required for publishing"
    exit 1
fi

# Check if the working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo "Git repository is not clean. There are uncommitted changes."
    exit 1
fi

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Version is required."
    exit 2
fi

echo $VERSION > VERSION

./clean.sh
./build.sh release

echo "Publishing to bin..."
rm -rf bin/dist
mkdir -p bin/dist

cp -r out/Release/* bin/dist

cd bin
git add *
git commit -m "Update SQLite Binaries $VERSION"
git push
git tag -m "v$VERSION" "v$VERSION"
git push --tags
cd ..
git add bin VERSION
git commit -m "Published SQLite Binaries $VERSION"
git push

pod spec lint sqlite3.podspec
if [ $? -ne 0 ]; then
    exit $?
fi

pod repo push tp-public sqlite3.podspec

cd android
./gradlew publishReleasePublicationToMavenRepository
