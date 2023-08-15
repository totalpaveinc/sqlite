
#pragma once

#include <sqlite3.h>

namespace TP { namespace sqlite { namespace extensions {

    class ConvertISO8601ToTimestamp {
        public:
            static int init(sqlite3* db);
            static void impl(sqlite3_context* context, int argc, sqlite3_value** argv);
    };

}}}
