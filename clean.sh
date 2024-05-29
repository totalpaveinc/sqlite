
source build-tools/public/assertions.sh
source build-tools/public/DirectoryTools.sh

spushd android
    rm -rf ./android/sqlite3/.cxx
    ./gradlew clean
    assertLastCall
spopd

spushd ios
    xcodebuild -quiet -workspace sqlite3.xcworkspace -scheme sqlite -configuration Release -destination "generic/platform=iOS" clean
    assertLastCall
    xcodebuild -quiet -workspace sqlite3.xcworkspace -scheme sqlite -configuration Debug -destination "generic/platform=iOS Simulator" clean
    assertLastCall
spopd

spushd npm
    rm -rf ./bin/sqlite3.xcframework
    rm -f package.json
    rm -f plugin.xml
    rm -f *.tgz
spopd

rm -rf ./dist
rm -rf ./src/sqlite/.libs
rm -rf ./src/sqlite/.deps
