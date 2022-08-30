
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

echo "Building Android AAR..."


ANDROID_JNI_LIBS=./android/sqlite3/src/main/jniLibs

mkdir -p $ANDROID_JNI_LIBS/arm64-v8a
mkdir -p $ANDROID_JNI_LIBS/armeabi-v7a
mkdir -p $ANDROID_JNI_LIBS/x86
mkdir -p $ANDROID_JNI_LIBS/x86_64

cp out/android/arm64-v8a/lib/libsqlite3.so $ANDROID_JNI_LIBS/arm64-v8a/libsqlite3.so
cp out/android/armeabi-v7a/lib/libsqlite3.so $ANDROID_JNI_LIBS/armeabi-v7a/libsqlite3.so
cp out/android/x86/lib/libsqlite3.so $ANDROID_JNI_LIBS/x86/libsqlite3.so
cp out/android/x86_64/lib/libsqlite3.so $ANDROID_JNI_LIBS/x86_64/libsqlite3.so

cd android

gradle wrapper
./gradlew build
