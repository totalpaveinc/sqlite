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

package com.totalpave.sqlite3;

public class Sqlite {
    static {
        System.loadLibrary("sqlite3");
    }

    // Note that only flags supported by sqlite3_open_v2 is supported.
    // The values come from https://www.sqlite.org/c3ref/c_open_autoproxy.html
    public static final int READ_ONLY       = 0x00000001;
    public static final int READ_WRITE      = 0x00000002;
    public static final int CREATE          = 0x00000004;
    public static final int URI             = 0x00000040;
    public static final int MEMORY          = 0x00000080;
    public static final int NO_MUTEX        = 0x00008000;
    public static final int FULL_MUTEX      = 0x00010000;
    public static final int SHARED_CACHE    = 0x00020000;
    public static final int PRIVATE_CACHE   = 0x00040000;
    public static final int NO_FOLLOW       = 0x01000000;

    /**
     * Sets the usable tmp directory.
     * This may be required if your queries can be large.
     * It must be set **once** on initialization. It's unsafe
     * to change this directory while any DBs are opened.
     */
    public static native void setTempDir(String path) throws SqliteException;

    /**
     * @param path
     * @param openFlags
     * @return Pointer to Database handler
     */
    public static native long open(String path, int openFlags) throws SqliteException;

    /**
     * @param db
     * @param sql
     * @return Pointer to statement handler
     */
    public static native long prepare(long db, String sql) throws SqliteException;

    public static native int bindDouble(long statement, String varName, double value) throws SqliteException;
    public static native int bindString(long statement, String varName, String value) throws SqliteException;
    public static native int bindInt(long statement, String varName, long value) throws SqliteException;
    public static native int bindBlob(long statement, String varName, byte[] value) throws SqliteException;
    public static native int bindNull(long statement, String varName) throws SqliteException;
    
    public static native int bindDoubleWithIndex(long statement, int index, double value) throws SqliteException;
    public static native int bindStringWithIndex(long statement, int index, String value) throws SqliteException;
    public static native int bindIntWithIndex(long statement, int index, long value) throws SqliteException;
    public static native int bindBlobWithIndex(long statement, int index, byte[] value) throws SqliteException;
    public static native int bindNullWithIndex(long statement, int index) throws SqliteException;

    public static native int step(long statement) throws SqliteException;
    public static native int reset(long statement) throws SqliteException;
    public static native int columnCount(long statement);
    public static native String columnName(long statement, int index);
    public static native int columnType(long statement, int index);

    public static native double getDouble(long statement, int index);
    public static native long getInt(long statement, int index);
    public static native String getString(long statement, int index);
    public static native byte[] getBlob(long statement, int index);

    public static native int finalize(long statement);
    public static native int close(long db);

    public static native String getLibVersion();
    public static native int setBusyTimeout(long db, int milliseconds);
}
