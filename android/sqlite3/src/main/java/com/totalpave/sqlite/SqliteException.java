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

import java.lang.Exception;
import java.lang.Throwable;
import org.json.JSONObject;
import org.json.JSONException;

public class SqliteException extends Exception {
    private String domain;
    private int code;
    private JSONObject details;

    public SqliteException(String domain, String message, int code) {
        super(message);
        this.domain = domain;
        this.code = code;
        this.details = null;
    }

    public SqliteException(String domain, String message, int code, SqliteException cause) {
        super(message, cause);
        this.domain = domain;
        this.code = code;
        this.details = null;
    }

    public SqliteException(String domain, String message, int code, JSONObject details) {
        super(message);
        this.domain = domain;
        this.code = code;
        this.details = details;
    }

    public SqliteException(String domain, String message, int code, JSONObject details, SqliteException cause) {
        super(message, cause);
        this.domain = domain;
        this.code = code;
        this.details = details;
    }

    public JSONObject toDictionary() throws JSONException {
        JSONObject error = new JSONObject();
        error.put("code", this.code);
        error.put("message", this.getMessage());
        error.put("name", this.domain);
        error.put("details", this.details);

        Throwable cause = this.getCause();
        if (cause != null) {
            error.put("cause", ((SqliteException)cause).toDictionary());
        }

        return error;
    }

    public void setDetails(JSONObject details) {
        this.details = details;
    }
}
