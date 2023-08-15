
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

cp -rf ./src/totalpave/include/tp ./ios/sqlite3/sqlite3/include/
cp -f ./src/totalpave/utilities.cpp ./ios/sqlite3/sqlite3/src
cp -rf ./src/totalpave/extensions ./ios/sqlite3/sqlite3/src
cp -f ./src/sqlite/sqlite3.h ./ios/sqlite3/sqlite3/include
cp -f ./src/sqlite/sqlite3.c ./ios/sqlite3/sqlite3/src
cp -f ./src/sqlite/sqlite3ext.h ./ios/sqlite3/sqlite3/include

mkdir -p ./out/$buildType/ios/frameworks/simulator
mkdir -p ./out/$buildType/ios/frameworks/phone
mkdir -p ./ios/build

xcodebuild -quiet -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3 -derivedDataPath ./ios clean
xcodebuild -quiet -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3 -configuration $buildType -sdk iphonesimulator -derivedDataPath ./ios/build build
xcodebuild -quiet -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3 -configuration $buildType -sdk iphoneos -arch arm64 -derivedDataPath ./ios/build build
cp -rf ./ios/build/Build/Products/$buildType-iphonesimulator/sqlite3.framework ./out/$buildType/ios/frameworks/simulator/sqlite3.framework
cp -rf ./ios/build/Build/Products/$buildType-iphoneos/sqlite3.framework ./out/$buildType/ios/frameworks/phone/sqlite3.framework
# Note xcodebuild -create-xcframework doesn't overwrite xcframework files.
rm -rf ./out/$buildType/ios/sqlite3.xcframework
xcodebuild -quiet -create-xcframework \
    -framework ./out/$buildType/ios/frameworks/simulator/sqlite3.framework \
    -framework ./out/$buildType/ios/frameworks/phone/sqlite3.framework \
    -output ./out/$buildType/ios/sqlite3.xcframework
