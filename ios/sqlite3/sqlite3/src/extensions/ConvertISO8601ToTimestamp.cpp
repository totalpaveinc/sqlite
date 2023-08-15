
#include <tp/sqlite/extensions/ConvertISO8601ToTimestamp.h>
#include <ctime>
#include <cstdio>

namespace TP { namespace sqlite { namespace extensions { namespace ConvertISO8601ToTimestamp {

    void _impl(
        sqlite3_context* context,
        int argc,
        sqlite3_value** argv
    ) {
        if (argc != 1) {
            sqlite3_result_error(context, "Usage: ConvertISO8601ToTimestamp(ISO8601)", -1);
            return;
        }

        const char* dateStr = (const char *)sqlite3_value_text(argv[0]);

        // start of custom manipulation (ChatGPT kept on recommending crap that would lose millisecond precision)
        int year, month, date, hour, minute, second, millisecond;
        sscanf(dateStr, "%d-%d-%dT%d:%d:%d.%dZ", &year, &month, &date, &hour, &minute, &second, &millisecond);

        struct tm time;
        time.tm_year = year - 1900; // Year since 1900
        time.tm_mon = month - 1;     // 0-11
        time.tm_mday = date;        // 1-31
        time.tm_hour = hour;        // 0-23
        time.tm_min = minute;         // 0-59
        time.tm_sec = second;    // 0-61 (0-60 in C++11)

        // end of custom manipulation

        time_t unix_time = mktime(&time);
        if (unix_time == -1) {
            sqlite3_result_error(context, "Failed to convert time", -1);
            return;
        }

        sqlite3_int64 timestamp = (unix_time * 1000) + millisecond;

        // Convert Unix timestamp to milliseconds
        sqlite3_result_int64(context, timestamp);
    }

    int init(
        sqlite3* db,
        const char** err//,
        // const sqlite3_api_routines *sqlite3_api
    ) {
        // SQLITE_EXTENSION_INIT2(sqlite3_api);

        // Create the function
        int status = sqlite3_create_function(
            db,
            "ConvertISO8601ToTimestamp",
            1,
            SQLITE_UTF8 | SQLITE_DETERMINISTIC,
            NULL,
            TP::sqlite::extensions::ConvertISO8601ToTimestamp::_impl,
            NULL,
            NULL
        );

        if (status != SQLITE_OK) {
            *err = sqlite3_mprintf(sqlite3_errmsg(db));
        }

        return sqlite3_extended_errcode(db);
    }

    // void _init(void) {

    // }
 
    // void init() {
    //     // TP::sqlite::extensions::ConvertISO8601ToTimestamp::_init();

    //     // void (*xEntryPoint)(void);
    //     // xEntryPoint = &TP::sqlite::extensions::ConvertISO8601ToTimestamp::_init;
    //     // sqlite3_auto_extension(xEntryPoint);

    //     void (*xEntryPoint)(void);
    //     xEntryPoint = (void(*)(void))(&TP::sqlite::extensions::ConvertISO8601ToTimestamp::_init);
    //     sqlite3_auto_extension(xEntryPoint);

    //     // sqlite3_auto_extension(reinterpret_cast<void(*)(void)>(TP::sqlite::extensions::ConvertISO8601ToTimestamp::$init));
    // }

}}}}
