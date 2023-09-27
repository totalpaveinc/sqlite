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

#ifndef TPISQLiteUtilities_h
#define TPISQLiteUtilities_h

#import <sqlite/sqlite3.h>

extern const NSString* TPISQLite_TP_ERROR_DOMAIN;
extern const NSString* TPISQLite_SQLITE_ERROR_DOMAIN;
extern const int TPISQLite_ERROR_CODE_BIND_PARAMETER_ERROR;
extern const int TPISQLite_ERROR_CODE_NO_DB;
extern const int TPISQLite_ERROR_CODE_ALLOC_FAILURE;

@interface TPISQLiteUtilities: NSObject

+ (int) lookupVariableIndex:(sqlite3_stmt*)  state var:(NSString*) variable;

@end

#endif
