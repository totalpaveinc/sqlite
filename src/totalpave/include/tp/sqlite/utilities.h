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

#pragma once

#include <string>
#include <sqlite3.h>

namespace TP { namespace sqlite {

    constexpr char const * const TOTALPAVE_SQLITE_ERROR_DOMAIN = "com.totalpave.sqlite3.ErrorDomain";
    constexpr char const * const SQLITE_ERROR_DOMAIN = "com.sqlite3.ErrorDomain";
    
    constexpr int const ERROR_CODE_BIND_PARAMETER_ERROR = 1;
    constexpr int const ERROR_CODE_NO_DB                = 2;
    constexpr int const ERROR_CODE_ALLOC_FAILURE        = 3;

    int lookupVariableIndex(sqlite3_stmt* state, const char* variable);

    int open(const char* path, sqlite3** db, int flags);
}}
