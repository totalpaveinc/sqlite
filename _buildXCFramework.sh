
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

cp -f ./src/totalpave/utilities.h ./ios/sqlite3/sqlite3/include/tp/sqlite
cp -f ./src/totalpave/utilities.cpp ./ios/sqlite3/sqlite3/src
cp -f ./src/sqlite/sqlite3.h ./ios/sqlite3/sqlite3/include
cp -f ./src/sqlite/sqlite3.c ./ios/sqlite3/sqlite3/src
cp -f ./src/sqlite/sqlite3ext.h ./ios/sqlite3/sqlite3/include

xcodebuild -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3 -derivedDataPath ./ios clean
xcodebuild -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3  -configuration Release -sdk iphonesimulator -derivedDataPath ./ios build
xcodebuild -project ./ios/sqlite3/sqlite3.xcodeproj -scheme sqlite3  -configuration Release -sdk iphoneos -derivedDataPath ./ios build    
cp -rf ./ios/Build/Products/Release-iphonesimulator/sqlite3.framework ./out/ios/x86_64
cp -rf ./ios/Build/Products/Release-iphoneos/sqlite3.framework ./out/ios/arm64
# Note xcodebuild -create-xcframework doesn't overwrite xcframework files.
rm -rf ./out/ios/sqlite3.xcframework
xcodebuild -create-xcframework \
    -framework ./out/ios/arm64/sqlite3.framework \
    -framework ./out/ios/x86_64/sqlite3.framework \
    -output ./out/ios/sqlite3.xcframework
