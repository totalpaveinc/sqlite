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
source build-tools/public/Checksum.sh

assertMac

VERSION=$(< VERSION)

echo "Building Android Frameworks"
spushd android
    ./gradlew :sqlite3:assembleRelease
    assertLastCall
spopd

mkdir -p dist/android
cp android/sqlite3/build/outputs/aar/sqlite3-release.aar dist/android/sqlite3.aar
assertLastCall

sha1_compute ./dist/android/sqlite3.aar
# echo $(sha1_compute ./dist/android/sqlite3.aar) > dist/android/sqlite3.aar.sha1.txt

echo "Building iOS Frameworks"
spushd ios
    xcodebuild -quiet -workspace sqlite3.xcworkspace -configuration Release -scheme sqlite -destination "generic/platform=iOS" build
    assertLastCall
    xcodebuild -quiet -workspace sqlite3.xcworkspace -configuration Debug -scheme sqlite -destination "generic/platform=iOS Simulator" build
    assertLastCall

    iosBuild=$(echo "$(xcodebuild -workspace sqlite3.xcworkspace -scheme sqlite -configuration Release -sdk iphoneos -showBuildSettings | grep "CONFIGURATION_BUILD_DIR")" | cut -d'=' -f2 | xargs)
    simBuild=$(echo "$(xcodebuild -workspace sqlite3.xcworkspace -scheme sqlite -configuration Debug -sdk iphonesimulator -showBuildSettings | grep "CONFIGURATION_BUILD_DIR")" | cut -d'=' -f2 | xargs)
spopd

mkdir -p dist/ios
rm -rf dist/ios/sqlite3.xcframework

xcodebuild -quiet -create-xcframework \
    -framework $iosBuild/sqlite.framework \
    -debug-symbols $iosBuild/sqlite.framework.dSYM \
    -framework $simBuild/sqlite.framework \
    -output dist/ios/sqlite3.xcframework
assertLastCall

spushd dist/ios
    zip -q sqlite3.xcframework.zip -r sqlite3.xcframework
    assertLastCall
spopd

sha1_compute ./dist/ios/sqlite3.xcframework.zip
# echo $(sha1_compute ./dist/ios/sqlite3.xcframework.zip) > dist/ios/sqlite3.xcframework.zip.sha1.txt

mkdir -p dist/cordova
spushd npm
echo -n $(cat package.template.json) > package.json
npm version $(cat ../VERSION) --no-git-tag-version --no-commit-hooks
assertLastCall
TGZ=$(npm pack)
cp $TGZ ../dist/cordova/cordova-plugin-libsqlite.tgz
spopd

mkdir -p dist/sqlite3-dev
rm -rf dist/sqlite3-dev/include
cp -r include dist/sqlite3-dev/
cp src/sqlite/sqlite3.h dist/sqlite3-dev/include/
cp src/sqlite/sqlite3ext.h dist/sqlite3-dev/include/
cp src/sqlite/sqlite3rc.h dist/sqlite3-dev/include/
mkdir -p dist/sqlite3-dev/lib/android
cp -r android/sqlite3/build/intermediates/library_and_local_jars_jni/release/jni/* dist/sqlite3-dev/lib/android/
assertLastCall

spushd dist
    zip -q ./sqlite3-dev.zip -r ./sqlite3-dev
spopd

sha1_compute ./dist/sqlite3-dev.zip

CHECKSUM=$(cat ./dist/ios/sqlite3.xcframework.zip.sha1.txt)

podspec=$(<sqlite3.podspec.template)
podspec=${podspec//\$VERSION\$/$VERSION}
podspec=${podspec//\$CHECKSUM\$/$CHECKSUM}

echo "$podspec" > sqlite3.podspec
