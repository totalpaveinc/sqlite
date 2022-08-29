echo "Building Android AAR..."


ANDROID_JNI_LIBS=./android/sqlite3/src/main/jniLibs

cp out/android/arm64-v8a/sqlite3/lib/libsqlite3.so $ANDROID_JNI_LIBS/arm64-v8a/libsqlite3.so
cp out/android/armeabi-v7a/sqlite3/lib/libsqlite3.so $ANDROID_JNI_LIBS/armeabi-v7a/libsqlite3.so
cp out/android/x86/sqlite3/lib/libsqlite3.so $ANDROID_JNI_LIBS/x86/libsqlite3.so
cp out/android/x86_64/sqlite3/lib/libsqlite3.so $ANDROID_JNI_LIBS/x86_64/libsqlite3.so

cd android

gradle wrapper
./gradlew build
