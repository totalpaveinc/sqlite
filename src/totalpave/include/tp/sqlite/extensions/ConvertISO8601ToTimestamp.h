
extern "C" {
    #include <sqlite3ext.h>
    SQLITE_EXTENSION_INIT1
}

namespace TP { namespace sqlite { namespace extensions { namespace ConvertISO8601ToTimestamp {
    // void init();
    // void _init(void);
    // int _init(
    //     sqlite3* db,
    //     const char** err,
    //     const sqlite3_api_routines *sqlite3_api
    // );
    int init(
        sqlite3* db,
        const char** err
    );
    void _impl(
        sqlite3_context* context,
        int argc,
        sqlite3_value** argv
    );
}}}}
