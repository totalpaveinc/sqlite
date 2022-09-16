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

#include <tp/sqlite/utilities.h>
#include <sqlite3.h>

namespace TP { namespace sqlite {
    
    int lookupVariableIndex(sqlite3_stmt* statement, const char* variable) {
        std::string strVar = variable;
        std::string boundVarName = ":" + strVar;
        return sqlite3_bind_parameter_index(statement, boundVarName.c_str());
    }

    std::string getErrorString(int code) {
        std::string error = "";

        switch(code) {
            case SQLITE_OK:
            case SQLITE_ROW:
            case SQLITE_DONE:
                // These cases are not errors, don't report anything...
                break;
            case SQLITE_ABORT:
                error = "SQLITE_ABORT: Operation was aborted.";
                break;
            case SQLITE_BUSY:
                error = "SQLITE_BUSY: Database already in use by another writer by another connection.";
                break;
            case SQLITE_CANTOPEN:
                error = "SQLITE_CANTOPEN";
                break;
            case SQLITE_CONSTRAINT:
                error = "SQLITE_CONSTRAINT: SQL Constraint violation.";
                break;
            case SQLITE_CORRUPT:
                error = "SQLITE_CORRUPT: Database is corrupted.";
                break;
            case SQLITE_EMPTY:
                error = "SQLITE_EMPTY: A code that you should not see.";
                break;
            case SQLITE_ERROR:
                error = "SQLITE_ERROR: An unknown SQLite error occurred.";
                break;
            case SQLITE_INTERNAL:
                error = "SQLITE_ERROR: An internal SQLite error occurred.";
                break;
            case SQLITE_PERM:
                error = "SQLITE_PERM: Permission denied.";
                break;
            case SQLITE_LOCKED:
                error = "SQLITE_LOCKED: Write operation cannot continue due to a lock from another operation.";
                break;
            case SQLITE_NOMEM:
                error = "SQLITE_NOMEM: Could not allocate memory.";
                break;
            case SQLITE_READONLY:
                error = "SQLITE_READONLY: Attempted to write on a readonly connection.";
                break;
            case SQLITE_INTERRUPT:
                error = "SQLITE_INTERRUPT: Operation was interrupted.";
                break;
            case SQLITE_IOERR:
                error = "SQLITE_IOERR: Underlying I/O error occurred.";
                break;
            case SQLITE_NOTFOUND:
                error = "SQLITE_NOTFOUND: See SQLite documentation.";
                break;
            case SQLITE_FULL:
                error = "SQLITE_FULL: Disk is full.";
                break;
            case SQLITE_PROTOCOL:
                error = "SQLITE_PROTOCOL: Failed to file lock. Should try again.";
                break;
            case SQLITE_SCHEMA:
                error = "SQLITE_SCHEMA: Schema has changed.";
                break;
            case SQLITE_TOOBIG:
                error = "SQLITE_TOOBIG: Blob or SQL statement is too large.";
                break;
            case SQLITE_MISMATCH:
                error = "SQLITE_MISMATCH: Data type mismatch.";
                break;
            case SQLITE_MISUSE:
                error = "SQLITE_MISUSE: Application error.";
                break;
            case SQLITE_NOLFS:
                error = "SQLITE_NOLFS: No Large File Support.";
                break;
            case SQLITE_AUTH:
                error = "SQLITE_AUTH: SQL Statement not authorized.";
                break;
            case SQLITE_RANGE:
                error = "SQLITE_RANGE: Bind/Column index is out of range.";
                break;
            case SQLITE_FORMAT:
                error = "SQLITE_FORMAT: Appearently not used.";
                break;
            case SQLITE_NOTADB:
                error = "SQLITE_NOTADB: DB does not appear to be a SQLite DB.";
                break;
            default:
                error = "An uncaught SQLite error (" + std::to_string(code) + ") have been reached.";
                break;
        }

        return error;
    }
}}
