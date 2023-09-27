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

#import <Foundation/Foundation.h>
#import <sqlite/TPISQLiteUtilities.h>
#include <tp/sqlite/Utilities.h>

using namespace TP::sqlite;

const NSString* TPISQLite_TP_ERROR_DOMAIN = [NSString stringWithUTF8String: TOTALPAVE_SQLITE_ERROR_DOMAIN];
const NSString* TPISQLite_SQLITE_ERROR_DOMAIN = [NSString stringWithUTF8String: SQLITE_ERROR_DOMAIN];
const int TPISQLite_ERROR_CODE_BIND_PARAMETER_ERROR = ERROR_CODE_BIND_PARAMETER_ERROR;
const int TPISQLite_ERROR_CODE_NO_DB = ERROR_CODE_NO_DB;
const int TPISQLite_ERROR_CODE_ALLOC_FAILURE = ERROR_CODE_ALLOC_FAILURE;

@implementation TPISQLiteUtilities

+ (int) lookupVariableIndex:(sqlite3_stmt*) state var:(NSString*) variable {
    return TP::sqlite::lookupVariableIndex(state, [variable UTF8String]);
}

@end
