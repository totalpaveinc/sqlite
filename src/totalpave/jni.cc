/*
    Copyright 2022 Total Pave Inc.

    Permission is hereby granted, free of charge, to any person obtaining a copy of this
    software and associated documentation files (the "Software"), to deal in the Software
    without restriction, including without limitation the rights to use, copy, modify,
    merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to the following
    conditions:

    The above copyright notice and this permission notice shall be included in all copies
    or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
    PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#ifdef ANDROID
#include <sqlite3.h>
#include <cstring>
#include <string>
#include <stdio.h>
#include <map>
#include <tp/sqlite/utilities.h>
#include <jni.h>
#include <unordered_map>

namespace sqlitejni_internal {
    // Map of statement to the db handle
    std::unordered_map<sqlite3_stmt*, sqlite3*> statementMap;
}

extern "C" {
    // We do not support the details object from here because of the complexities.
    // The details object is an key-value pair object of arbitrary values - We don't know what is it in.
    // In addition, java is very type strict. add(string, string), add(string, double), add(string, int), add(string, bool).
    // We would have to do a lot of type checking and write a considerable amount of code to support the details object.
    // Instead, the SqliteException provides a setDetails function for java-side code.
    jint throwJavaException(JNIEnv *env, const char* domain, const char* message, int code) {
        const char* className = "com/totalpave/sqlite3/SqliteException" ;
        jclass exClass = env->FindClass(className);
        // public SQLiteError(String domain, String message, int code) {
        // Refer to https://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/types.html for details regarding the 4th parameter.
        // In addition, oracle's JNIEnv documentation is incorrect, it says there are 4 parameters, the first being JNIEnv but compilation fails saying there are 3 parameters.
        // Android documentation examples use 3 parameters and don't pass in the JNIEnv. See https://developer.android.com/training/articles/perf-jni for examples.
        jmethodID constructor = env->GetMethodID(exClass, "<init>", "(Ljava/lang/String;Ljava/lang/String;I)V");
        return env->Throw((jthrowable)env->NewObject(exClass, constructor, env->NewStringUTF(domain), env->NewStringUTF(message), code));
    }

    jint throwStatementError(JNIEnv* env, jlong jstatement) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;

        // We do .find vs [] operator because .find will not modify the map,
        //whereas [] operator will insert a new uninitialized property onto the map.
        if (sqlitejni_internal::statementMap.find(statement) == sqlitejni_internal::statementMap.end()) {
            // There is no db for this statement. Potential use after free?
            return throwJavaException(env, TP::sqlite::TOTALPAVE_SQLITE_ERROR_DOMAIN, "No DB tied to this statement. Are you using a freed statement?", TP::sqlite::ERROR_CODE_NO_DB);
        }

        sqlite3* db = sqlitejni_internal::statementMap[(sqlite3_stmt*)jstatement];
        return throwJavaException(env, TP::sqlite::SQLITE_ERROR_DOMAIN, sqlite3_errmsg(db), sqlite3_extended_errcode(db));
    }

    jint throwDBError(JNIEnv* env, jlong sqlite3db) {
        sqlite3* db = (sqlite3*)sqlite3db;
        return throwJavaException(env, TP::sqlite::SQLITE_ERROR_DOMAIN, sqlite3_errmsg(db), sqlite3_extended_errcode(db));
    }

    // JNIEXPORT void JNICALL
    // Java_com_totalpave_sqlite3_Sqlite_releaseException(JNIEnv* env, jobject jptr) {
    //     env->DeleteGlobalRef(jptr);
    // }

    // Old FindClass,GetMethodID, NewObject code that was written by norman.
    // sqlite3_stmt* stmt = (sqlite3_stmt*)jstatement;
    // int index = (int)jindex;
    // jobject retval;
    // if (sqlite3_column_type(stmt, index) == SQLITE_NULL) {
    //     retval = NULL;
    // }
    // else {
    //     jclass intClass = env->FindClass("java/lang/Double");
    //     jmethodID constructor = env->GetMethodID(intClass, "<init>", "(D)V"); // (ParameterTypes)Return Type
    //     double value = sqlite3_column_double(stmt, index);
    //     retval = env->NewObject(intClass, constructor, value);
    // }
    // return retval;

    jint throwBindError(JNIEnv *env, std::string varName, jstring jVarName) {
        std::string message = "Could not bind parameter \"" + varName + "\"";
        return throwJavaException(env, TP::sqlite::TOTALPAVE_SQLITE_ERROR_DOMAIN, message.c_str(), TP::sqlite::ERROR_CODE_BIND_PARAMETER_ERROR);
    }

    JNIEXPORT void JNICALL
    Java_com_totalpave_sqlite3_Sqlite_setTempDir(JNIEnv* env, jobject jptr, jstring jpath) {
        // Read special notes: https://www.sqlite.org/c3ref/temp_directory.html
        jboolean isCopy;
        const char* path = env->GetStringUTFChars(jpath, &isCopy);

        if (path == NULL) {
            sqlite3_temp_directory = NULL;
            return;
        }

        std::size_t len = strlen(path) + 1; // +1 for NULL terminator
        char* sqliteStr = (char*)sqlite3_malloc(len);

        if (sqliteStr == NULL) {
            // Allocation failure
            throwJavaException(env, TP::sqlite::TOTALPAVE_SQLITE_ERROR_DOMAIN, "Unable to allocate temp directory path", TP::sqlite::ERROR_CODE_ALLOC_FAILURE);
            return;
        }

        strcpy(sqliteStr, path);

        sqlite3_temp_directory = sqliteStr;
    }

    JNIEXPORT jlong JNICALL
    Java_com_totalpave_sqlite3_Sqlite_open(JNIEnv* env, jobject jptr, jstring jpath, jint jflags) {
        sqlite3* db;
        jboolean isCopy;
        const char* path = env->GetStringUTFChars(jpath, &isCopy);
        int resultCode = sqlite3_open_v2(path, &db, (int)jflags, nullptr);
        if (resultCode != SQLITE_OK) {
            std::string message = std::string(sqlite3_errstr(resultCode)) + " (" + std::string(path) + ")";
            env->ReleaseStringUTFChars(jpath, path);
            return throwJavaException(env, TP::sqlite::SQLITE_ERROR_DOMAIN, message.c_str(), resultCode);
        }
        env->ReleaseStringUTFChars(jpath, path);
        return (jlong)db;
    }

    JNIEXPORT jlong JNICALL
    Java_com_totalpave_sqlite3_Sqlite_prepare(JNIEnv* env, jobject jptr, jlong jdbptr, jstring jsql) {
        sqlite3* db = (sqlite3*)jdbptr;
        jboolean isCopy;
        const char* sql = env->GetStringUTFChars(jsql, &isCopy);

        sqlite3_stmt* statement;
        int resultCode = sqlite3_prepare_v2(db, sql, strlen(sql), &statement, 0);
        env->ReleaseStringUTFChars(jsql, sql);
        if (resultCode != SQLITE_OK) {
            return throwDBError(env, jdbptr);
        }

        sqlitejni_internal::statementMap[statement] = db;

        return (jlong)statement;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindNullWithIndex(JNIEnv* env, jobject jptr, jlong jstatement, jint jIndex) {
        int resultCode = sqlite3_bind_null((sqlite3_stmt*)jstatement, (int)jIndex);
        if (resultCode != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindNull(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            jint result = throwBindError(env, varName, jVarName);
            env->ReleaseStringUTFChars(jVarName, varName);
            return result;
        }
        env->ReleaseStringUTFChars(jVarName, varName);

        return Java_com_totalpave_sqlite3_Sqlite_bindNullWithIndex(env, jptr, jstatement, index);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindDoubleWithIndex(JNIEnv* env, jobject jptr, jlong jstatement, jint jIndex, jdouble value) {
        int resultCode = sqlite3_bind_double((sqlite3_stmt*)jstatement, jIndex, (double)value);
        if (resultCode != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindDouble(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jdouble value) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            jint result = throwBindError(env, varName, jVarName);
            env->ReleaseStringUTFChars(jVarName, varName);
            return result;
        }
        env->ReleaseStringUTFChars(jVarName, varName);

        return Java_com_totalpave_sqlite3_Sqlite_bindDoubleWithIndex(env, jptr, jstatement, index, value);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindStringWithIndex(JNIEnv* env, jobject jptr, jlong jstatement, jint jIndex, jstring jvalue) {
        jboolean isCopy;
        const char* value = env->GetStringUTFChars(jvalue, &isCopy);
        int resultCode = sqlite3_bind_text((sqlite3_stmt*)jstatement, jIndex, value, strlen(value), SQLITE_TRANSIENT);
        env->ReleaseStringUTFChars(jvalue, value);
        if (resultCode != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindString(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jstring jvalue) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            jint result = throwBindError(env, varName, jVarName);
            env->ReleaseStringUTFChars(jVarName, varName);
            return result;
        }
        env->ReleaseStringUTFChars(jVarName, varName);

        return Java_com_totalpave_sqlite3_Sqlite_bindStringWithIndex(env, jptr, jstatement, index, jvalue);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindIntWithIndex(JNIEnv* env, jobject jptr, jlong jstatement, jint jIndex, jint value) {
        int resultCode = sqlite3_bind_int((sqlite3_stmt*)jstatement, jIndex, (int)value);
        if (resultCode != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindInt(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jint value) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            jint result = throwBindError(env, varName, jVarName);
            env->ReleaseStringUTFChars(jVarName, varName);
            return result;
        }
        env->ReleaseStringUTFChars(jVarName, varName);

        return Java_com_totalpave_sqlite3_Sqlite_bindIntWithIndex(env, jptr, jstatement, index, value);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindBlobWithIndex(JNIEnv* env, jobject jptr, jlong jstatement, jint jIndex, jbyteArray jvalue) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;

        int result;
        if (jvalue == NULL) {
            result = sqlite3_bind_blob(statement, jIndex, NULL, 0, NULL);
        }
        else {
            jbyte* bufferPtr = env->GetByteArrayElements(jvalue, NULL);
            jsize lengthOfArray = env->GetArrayLength(jvalue);

            result = sqlite3_bind_blob(statement, jIndex, bufferPtr, (int)lengthOfArray, SQLITE_TRANSIENT);

            env->ReleaseByteArrayElements(jvalue, bufferPtr, 0);
        }

        if (result != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return result;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_bindBlob(JNIEnv* env, jobject jptr, jlong jstatement, jstring jVarName, jbyteArray jvalue) {
        sqlite3_stmt* statement = (sqlite3_stmt*)jstatement;
        jboolean isCopy;
        const char* varName = env->GetStringUTFChars(jVarName, &isCopy);
        int index = TP::sqlite::lookupVariableIndex(statement, varName);
        if (index == 0) {
            jint result = throwBindError(env, varName, jVarName);
            env->ReleaseStringUTFChars(jVarName, varName);
            return result;
        }
        env->ReleaseStringUTFChars(jVarName, varName);

        return Java_com_totalpave_sqlite3_Sqlite_bindBlobWithIndex(env, jptr, jstatement, index, jvalue);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_step(JNIEnv* env, jobject jptr, jlong jstatement) {
        int resultCode = sqlite3_step((sqlite3_stmt*)jstatement);
        if (resultCode != SQLITE_OK && resultCode != SQLITE_DONE && resultCode != SQLITE_ROW) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_reset(JNIEnv* env, jobject jptr, jlong jstatement) {
        int resultCode = sqlite3_reset((sqlite3_stmt*)jstatement);
        if (resultCode != SQLITE_OK) {
            return throwStatementError(env, jstatement);
        }
        return resultCode;
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

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_columnType(JNIEnv* env, jobject jptr, jlong jstatement, jint index) {
        return sqlite3_column_type((sqlite3_stmt*)jstatement, (int)index);
    }

    JNIEXPORT jdouble JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getDouble(JNIEnv* env, jobject jptr, jlong jstatement, jint jindex) {
        return (jdouble)sqlite3_column_double((sqlite3_stmt*)jstatement, (int)jindex);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getInt(JNIEnv* env, jobject jptr, jlong jstatement, jint jindex) {
        return (jint)sqlite3_column_int((sqlite3_stmt*)jstatement, (int)jindex);
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
        sqlitejni_internal::statementMap.erase((sqlite3_stmt*)jstatement);
        return (jint)sqlite3_finalize((sqlite3_stmt*)jstatement);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_close(JNIEnv* env, jobject jptr, jlong db) {
        return (jint)sqlite3_close_v2((sqlite3*)db);
    }

    JNIEXPORT jstring JNICALL
    Java_com_totalpave_sqlite3_Sqlite_getLibVersion(JNIEnv* env, jobject jptr) {
        const char* version = sqlite3_libversion();
        return env->NewStringUTF((const char*)version);
    }

    JNIEXPORT jint JNICALL
    Java_com_totalpave_sqlite3_Sqlite_setBusyTimeout(JNIEnv* env, jobject jptr, jlong db, jint milliseconds) {
        return (jint)sqlite3_busy_timeout((sqlite3*)db, (int)milliseconds);
    }
}

#endif
