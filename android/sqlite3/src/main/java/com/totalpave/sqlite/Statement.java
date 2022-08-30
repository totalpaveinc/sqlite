
package com.totalpave.sqlite;

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

public class Statement {
    public static final int OK              = 0;   /* Successful result */
    /* beginning-of-error-codes */
    public static final int ERROR           =  1;   /* Generic error */
    public static final int INTERNAL        =  2;   /* Internal logic error in SQLite */
    public static final int PERM            =  3;   /* Access permission denied */
    public static final int ABORT           =  4;   /* Callback routine requested an abort */
    public static final int BUSY            =  5;   /* The database file is locked */
    public static final int LOCKED          =  6;   /* A table in the database is locked */
    public static final int NOMEM           =  7;   /* A malloc() failed */
    public static final int READONLY        =  8;   /* Attempt to write a readonly database */
    public static final int INTERRUPT       =  9;   /* Operation terminated by sqlite3_interrupt()*/
    public static final int IOERR           = 10;   /* Some kind of disk I/O error occurred */
    public static final int CORRUPT         = 11;   /* The database disk image is malformed */
    public static final int NOTFOUND        = 12;   /* Unknown opcode in sqlite3_file_control() */
    public static final int FULL            = 13;   /* Insertion failed because database is full */
    public static final int CANTOPEN        = 14;   /* Unable to open the database file */
    public static final int PROTOCOL        = 15;   /* Database lock protocol error */
    public static final int EMPTY           = 16;   /* Internal use only */
    public static final int SCHEMA          = 17;   /* The database schema changed */
    public static final int TOOBIG          = 18;   /* String or BLOB exceeds size limit */
    public static final int CONSTRAINT      = 19;   /* Abort due to constraint violation */
    public static final int MISMATCH        = 20;   /* Data type mismatch */
    public static final int MISUSE          = 21;   /* Library used incorrectly */
    public static final int NOLFS           = 22;   /* Uses OS features not supported on host */
    public static final int AUTH            = 23;   /* Authorization denied */
    public static final int FORMAT          = 24;   /* Not used */
    public static final int RANGE           = 25;   /* 2nd parameter to sqlite3_bind out of range */
    public static final int NOTADB          = 26;   /* File opened that is not a database file */
    public static final int NOTICE          = 27;   /* Notifications from sqlite3_log() */
    public static final int WARNING         = 28;   /* Warnings from sqlite3_log() */
    public static final int ROW             = 100;  /* sqlite3_step() has another row ready */
    public static final int DONE            = 101;  /* sqlite3_step() has finished executing */
}
