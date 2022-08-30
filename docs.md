# Documentation

This outlines the documentation of this package.

## iOS

There are no iOS specific code. Refer to SQLite's [C/C++ Reference](https://www.sqlite.org/c3ref/intro.html).

## Android

This package includes JNI bindings. It loosely follows the C API, but is not a complete binding.
For a complete solution, it might be wise to use SQLite's [Precompiled AAR](https://www.sqlite.org/download.html) instead.

Android JNI bindings are packaged under a static class `com.totalpave.sqlite.Sqlite`

Note: Android Bindings only supports SQLite's v2 APIs.

##### Open Flags

See SQLite documentation for [more information](https://www.sqlite.org/c3ref/c_open_autoproxy.html).

```java
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
```

##### long open(String path, int openFlags)

|Type|Parameter|Description|
|----|---|---|
|String|path|The path to the SQLite database file.
|int|openFlags|Bitmask value of open flags.

**Returns** a `long` value, representing a handle to the database.
When done, the handle should be closed using the `close` method.

Will throw exception if the database could not be opened.

##### long prepare(long dbHandle, String sql)

|Type|Parameter|Description|
|----|---|---|
|long|dbHandle|A database handle value, returned from an `open` call.
|String|sql|An SQL statement.

**Returns** a long value representing a statement handle. When finished, it should be `finalize` to release resources.

The SQL statement may have parameterized keywords in the form of `:variableName`. Use the `bind` methods to bind values to variables.

##### Binding variables

The following methods are available to bind variables by variable name. The return value is an `int` indicating status.

|Type|Parameter|Description|
|----|---|---|
|long|statementHandle|A statement handle value, returned from a `prepare` call.
|String|variableName|The variable to bind the value with
|*|value|The value to bind. See below for supported types

Supported data types are:
- double
- int
- byte[]
- String 

```java
public static native int bindDouble(long statementHandle, String varName, double value);
public static native int bindString(long statementHandle, String varName, String value);
public static native int bindInt(long statementHandle, String varName, int value);
public static native int bindBlob(long statementHandle, String varName, byte[] value);
```

##### int step(long statementHandle)

Returns a status code. Increments a statement's step, and prepares the context to contain the next row data.

If returned value is `SQLITE_ROW`, then a row is present.
If returned value is `SQLITE_DONE`, the result iteration has been completed.

##### Reading Results

Columns can be read using the `get` methods. Index are 0-based indices of the column position inside the `SELECT` statement.

See the interface:

```java
public static native double getDouble(long statement, int index);
public static native int getInt(long statement, int index);
public static native String getString(long statement, int index);
public static native byte[] getBlob(long statement, int index);
```

##### int finalize(long statementHandle)

Closes a statement and frees resources. Using the statement handle after finalizing will result in undefined behaviour, likely an application crash.

##### int close(long dbHandle)

Closes a database and frees resources. Using the database handle after closing will result in undefined behaviour, likely an application crash.
