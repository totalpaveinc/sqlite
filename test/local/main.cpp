
#include <iostream>
#include <sqlite3.h>
#include <cstring>

#include <stdio.h>
#include <execinfo.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <tp/sqlite/utilities.h>
    
void handler(int sig) {
    void *array[10];
    size_t size;

    // get void*'s for all entries on the stack
    size = backtrace(array, 10);

    // print out all the frames to stderr
    fprintf(stderr, "Error: signal %d:\n", sig);
    backtrace_symbols_fd(array, size, STDERR_FILENO);
    exit(1);
}

int insertRow(sqlite3* db, int id, const char* name, double height, const void* data, int dataLength) {
    sqlite3_stmt* statement;
    const char* insertStatement = "INSERT INTO test VALUES (:id, :name, :height, :data)";
    int result = 0;
    result = sqlite3_prepare_v2(db, insertStatement, strlen(insertStatement), &statement, NULL);
    if (result != SQLITE_OK || statement == NULL) {
        std::cout << "Failed to prepare insert statement" << std::endl;
        return result;
    }

    result = sqlite3_bind_int(
        statement,
        TP::sqlite::lookupVariableIndex(statement, "id"),
        id
    );
    if (result != SQLITE_OK) {
        return result;
    }

    result = sqlite3_bind_text(
        statement,
        TP::sqlite::lookupVariableIndex(statement, "name"),
        name,
        strlen(name),
        NULL
    );
    if (result != SQLITE_OK) {
        return result;
    }

    result = sqlite3_bind_double(
        statement,
        TP::sqlite::lookupVariableIndex(statement, "height"),
        height
    );
    if (result != SQLITE_OK) {
        return result;
    }

    result = sqlite3_bind_blob(
        statement,
        TP::sqlite::lookupVariableIndex(statement, "data"),
        data, dataLength, SQLITE_STATIC
    );
    if (result != SQLITE_OK) {
        return result;
    }

    result = sqlite3_step(statement);
    if (result != SQLITE_OK) {
        return result;
    }

    result = sqlite3_finalize(statement);
    if (result != SQLITE_OK) {
        return result;
    }

    return result;
}

int main(int argc, char** argv) {
    signal(SIGSEGV, handler);

    std::cout << "SQLite Version: " << SQLITE_VERSION << std::endl;

    sqlite3* db = NULL;
    int result = 0;
    result = sqlite3_open_v2("./test.db", &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL);

    if (result != SQLITE_OK || db == NULL) {
        return result;
    }

    const char* createSchema = "CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL, name TEXT NOT NULL, height REAL, data BLOB)";
    sqlite3_stmt* statement = NULL;

    result = sqlite3_prepare_v2(db, createSchema, strlen(createSchema), &statement, NULL);
    if (result != SQLITE_OK || statement == NULL) {
        return result;
    }
    result = sqlite3_step(statement);
    if (result != SQLITE_DONE) {
        return result;
    }
    sqlite3_finalize(statement);

    const char* truncateSchema = "DELETE FROM test";
    result = sqlite3_prepare_v2(db, truncateSchema, strlen(truncateSchema), &statement, NULL);
    if (result != SQLITE_OK) {
        return result;
    }
    result = sqlite3_step(statement);
    if (result != SQLITE_DONE) {
        return result;
    }
    sqlite3_finalize(statement);

    const uint8_t data = 0x11;
    insertRow(db, 1, "John Smith", 3.14, NULL, 0);
    insertRow(db, 2, "Norman Breau", 5.7, NULL, 0);
    insertRow(db, 2, "Tyler Breau", 5.8, (void*)&data, sizeof(uint8_t));

    const char* selectQuery = "SELECT * FROM test";
    result = sqlite3_prepare_v2(db, selectQuery, strlen(selectQuery), &statement, NULL);
    if (result != SQLITE_OK) {
        return result;
    }

    while (true) {
        int code = sqlite3_step(statement);

        if (code == SQLITE_DONE) {
            result = SQLITE_OK;
            break;
        }
        else if (code == SQLITE_ROW) {
            int id = sqlite3_column_int(statement, 0);
            const char* name = (const char*)sqlite3_column_text(statement, 1);
            double height = sqlite3_column_double(statement, 2);
            const void* data = sqlite3_column_blob(statement, 3);
            int dataLength = sqlite3_column_bytes(statement, 3);

            printf("ID: %d\nName: %s\nHeight: %f\nData: ", id, name, height);
            for (int i = 0; i < dataLength; i++) {
                printf("%02x", ((uint8_t*)data)[i]);
            }
            printf("\n");
        }
        else {
            result = code;
            break;
        }
    }

    if (result != SQLITE_OK) {
        return result;
    }

    sqlite3_finalize(statement);
    sqlite3_close_v2(db);

    return 0;
}
