// Copyright 2022 Total Pave Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#include <sqlite3.h>
#include <cstring>
#include <string>

namespace TP { namespace sqlite {
    int lookupVariableIndex(sqlite3_stmt* statement, const char* variable) {
        std::string strVar = variable;
        std::string boundVarName = ":" + strVar;
        return sqlite3_bind_parameter_index(statement, boundVarName.c_str());
    }
}}

#ifdef ANDROID
#include <jni.h>

extern "C" {

    jint throwNoClassDefError(JNIEnv *env, const char* message ) {
        jclass exClass;
        const char *className = "java/lang/NoClassDefFoundError";

        exClass = env->FindClass(className);
        if (exClass == NULL) {
            return throwNoClassDefError(env, className );
        }

        return env->ThrowNew(exClass, message);
    }

    jint throwRuntimeException(JNIEnv *env, const char* message) {
        jclass exClass;
        const char* className = "java/lang/RuntimeException" ;

        exClass = env->FindClass(className);
        if (exClass == NULL) {
            return throwNoClassDefError(env, className);
        }

        return env->ThrowNew(exClass, message);
    }

    JNIEXPORT jlong JNICALL
    Java_com_totalpave_sqlite3_Sqlite_open(JNIEnv* env, jobject jptr, jstring jpath, jint jflags) {
        sqlite3* db;
        jboolean isCopy;
        const char* path = env->GetStringUTFChars(jpath, &isCopy);
        int resultCode = sqlite3_open_v2(path, &db, (int)jflags, nullptr);
        if (resultCode != SQLITE_OK) {
            return throwRuntimeException(env, "Could not open SQLite Database.");
        }

        return (jlong)db;
    }

    JNIEXPORT jlong JNICALL
    Java_com_totalpave_sqlite3_Sqlite_prepare(JNIEnv* env, jobject jptr, jlong jdbptr, jstring jsql) {
        sqlite3* db = (sqlite3*)jdbptr;
        jboolean isCopy;
        const char* sql = env->GetStringUTFChars(jsql, &isCopy);

        sqlite3_stmt* statement;
        int returnCode = sqlite3_prepare_v2(db, sql, strlen(sql), &statement, 0);
        if (returnCode != SQLITE_OK) {
            return throwRuntimeException(env, "Could not parse SQL.");
        }

        return (jlong)statement;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindDouble(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jdouble value) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            std::string pname = varName;
            std::string message = "Could not bind parameter \"" + pname + "\"";
            return throwRuntimeException(env, message.c_str());
        }

        return sqlite3_bind_double(statement, index, (double)value);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindString(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jstring jvalue) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            std::string pname = varName;
            std::string message = "Could not bind parameter \"" + pname + "\"";
            return throwRuntimeException(env, message.c_str());
        }

        const char* value = env->GetStringUTFChars(jvalue, &isCopy);

        return sqlite3_bind_text(statement, index, value, strlen(value), NULL);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindInt(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jint value) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            std::string pname = varName;
            std::string message = "Could not bind parameter \"" + pname + "\"";
            return throwRuntimeException(env, message.c_str());
        }

        return sqlite3_bind_int(statement, index, (int)value);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindBlob(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jbyteArray jvalue) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            std::string pname = varName;
            std::string message = "Could not bind parameter \"" + pname + "\"";
            return throwRuntimeException(env, message.c_str());
        }

        int result;

        if (jvalue == NULL) {
            result = sqlite3_bind_blob(statement, index, NULL, 0, NULL);
        }
        else {
            jbyte* bufferPtr = env->GetByteArrayElements(jvalue, NULL);
            jsize lengthOfArray = env->GetArrayLength(jvalue);

            result = sqlite3_bind_blob(statement, index, bufferPtr, (int)lengthOfArray, NULL);

            env->ReleaseByteArrayElements(jvalue, bufferPtr, 0);
        }

        return result;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_step(JNIEnv* env, jobject jptr, jlong jstatement) {
        return sqlite3_step((sqlite3_stmt*)jstatement);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_columnCount(JNIEnv* env, jobject jptr, jlong jstatement) {
        return sqlite3_column_count((sqlite3_stmt*)jstatement);
    }

    JNIEXPORT jstring JNICALL
    Java_com_totalpave_sqlite3_Sqlite_columnName(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        const char* columnName = sqlite3_column_name((sqlite3_stmt*)jstatement, (int)index);
        return env->NewStringUTF(columnName);
    }

    JNIEXPORT jdouble JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getDouble(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        return (jdouble)sqlite3_column_double((sqlite3_stmt*)jstatement, (int)index);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getInt(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        return (jint)sqlite3_column_int((sqlite3_stmt*)jstatement, (int)index);
    }

    JNIEXPORT jstring JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getString(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        const unsigned char* text = sqlite3_column_text((sqlite3_stmt*)jstatement, (int)index);
        return env->NewStringUTF((const char*)text);
    }

    JNIEXPORT jbyteArray JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getBlob(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        const void* data = sqlite3_column_blob(statement, (int)index);
        int size = sqlite3_column_bytes(statement, (int)index);
        jbyteArray out = env->NewByteArray(size);
        env->SetByteArrayRegion(out, 0, size, (jbyte*)data);
        return out;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_finalize(JNIEnv* env, jobject jptr, jlong jstatement) {
        return (jint)sqlite3_finalize((sqlite3_stmt*)jstatement);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_close(JNIEnv* env, jobject jptr, jlong db) {
        return (jint)sqlite3_close_v2((sqlite3*)db);
    }
}

#endif
