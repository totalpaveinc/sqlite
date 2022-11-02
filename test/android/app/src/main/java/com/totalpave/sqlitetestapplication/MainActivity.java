package com.totalpave.sqlitetestapplication;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;

import com.totalpave.sqlite3.Statement;
import com.totalpave.sqlite3.Sqlite;
import com.totalpave.sqlite3.SqliteException;
import java.io.File;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i("UnitTest", "SQLite Version: " + Sqlite.getLibVersion());

        File dataDirectory = getApplicationContext().getFilesDir();
        String dbPath = dataDirectory.getAbsolutePath() + "/test.db";

        long db;
        try {
            db = Sqlite.open(dbPath, Sqlite.CREATE | Sqlite.READ_WRITE);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Could not open db", ex);
            return;
        }
        long statement;
        try {
            statement = Sqlite.prepare(db, "CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL, name TEXT NOT NULL, height REAL, data BLOB)");
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Could not prepare statement", ex);
            Sqlite.close(db);
            return;
        }

        try {
            Sqlite.step(statement);
            Sqlite.finalize(statement);

            //       statement = Sqlite.prepare(db, "INSERT INTO test VALUES (:id, :name, :height, :blob)");
            //       Sqlite.bindInt(statement, "id", 2);
            //       Sqlite.bindString(statement, "name", "Person B");
            //       Sqlite.bindDouble(statement, "height", 3.14);
            //       Sqlite.bindBlob(statement, "blob", null);
            //
            //       Sqlite.step(statement);
            //       Sqlite.finalize(statement);

            statement = Sqlite.prepare(db, "SELECT * FROM test");

            int rowCount = 0;
            while (true) {
                int result = Sqlite.step(statement);
                if (result == Statement.ROW) {
                    rowCount++;
                    int id = Sqlite.getInt(statement, 0);
                    String name = Sqlite.getString(statement, 1);
                    double height = Sqlite.getDouble(statement, 2);
                    byte[] data = Sqlite.getBlob(statement, 4);

                    StringBuilder sb = new StringBuilder();
                    sb.append("Row ").append(rowCount).append(":\n")
                            .append("ID: ").append(id).append("\n")
                            .append("Name: ").append(name).append("\n")
                            .append("Height: ").append(height).append("\n");

                    String msg = sb.toString();
                    Log.i("UnitTest", msg);
                } else if (result == Statement.DONE) {
                    // Exit without error
                    break;
                } else {
                    Log.e("UnitTest", "Statement error: " + result);
                    break;
                }
            }
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Could not successfully run queries", ex);
            Sqlite.finalize(statement);
            Sqlite.close(db);
            return;
        }

        try {
            Sqlite.open("db that does not exist", Sqlite.CREATE | Sqlite.READ_WRITE);
            Log.e("UnitTest", "Bad db open did not error.");
        }
        catch (SqliteException ex) {
            Log.i("UnitTest", "Caught expected error for bad open db.");
        }

        try {
            statement = Sqlite.prepare(db, "asdasfafasda");
            Log.e("UnitTest", "Bad prepare did not error.");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.i("UnitTest", "Caught expected error for bad prepare.");
        }

        try {
            statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = :id");
            Sqlite.step(statement);

            //https://www.sqlite.org/lang_expr.html#varparam
            //Parameters that are not assigned values using sqlite3_bind() are treated as NULL. The sqlite3_bind_parameter_index() interface can be used to translate a symbolic parameter name into its equivalent numeric index.

            Log.i("UnitTest", "Bad step (unbound variable) did not error (expected result).");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Caught unexpected error for bad step (unbound variable).", ex);
        }

        try {
            int resultCode = Sqlite.bindInt(0, "id", 2);
            Log.e("UnitTest", "Bad bind (null pointer to statement) did not error. Code:" + Integer.toString(resultCode));
        }
        catch (SqliteException ex) {
            Log.i("UnitTest", "Caught expected error for bad bind (null pointer to statement).");
        }

        try {
            statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = :id");
            Sqlite.bindInt(statement, "id", 2);
            // Result should have 1 row
            Sqlite.step(statement); // Go to first row
            Sqlite.step(statement); // Go to second row (should not exist)

            // https://www.sqlite.org/c3ref/step.html
            // For all versions of SQLite up to and including 3.6.23.1, a call to sqlite3_reset()
            // was required after sqlite3_step() returned anything other than SQLITE_ROW before
            // any subsequent invocation of sqlite3_step(). Failure to reset the prepared statement
            // using sqlite3_reset() would result in an SQLITE_MISUSE return from sqlite3_step().
            // But after version 3.6.23.1 (2010-03-26, sqlite3_step() began calling sqlite3_reset()
            // automatically in this circumstance rather than returning SQLITE_MISUSE.
            // This is not considered a compatibility break because any application that ever receives
            // an SQLITE_MISUSE error is broken by definition. The SQLITE_OMIT_AUTORESET compile-time
            // option can be used to restore the legacy behavior.


            Log.i("UnitTest", "Bad step (step to non-existent row) did not error (expected result).");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Caught unexpected error for bad step (step to non-existent row) As of SQLite3 >3.6.23.1, sqlite3_step calls sqlite3_reset, which should have prevented this error.", ex);
        }

        // Calling step after finalize should return SQLITE_MISUSE but it's ultimately undefined behaviour.
        // So anything can happen. During my tests, it was hard-crashing with an uncatchable error.
        // While creating a preventative system is probably possible, we've decided it would be high-cost-low-reward.
        // Error cases that could run in to this is not something that randomly happens because of runtime data.
        // The code path is literally just written incorrectly.
        // As such we have no way of gracefully handling this error path and we are simply commenting out the try-catch block.
        //try {
        //    statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = :id");
        //    Sqlite.bindInt(statement, "id", 2);
        //    Sqlite.finalize(statement);
        //    Sqlite.step(statement);
        //    Log.e("UnitTest", "Bad step (step after finalize) did not error.");
        //}
        //catch (SqliteException ex) {
        //    Log.i("UnitTest", "Caught expected error for bad step (step after finalize).");
        //}

        try {
            statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = :mystring OR id = :myint OR id = :mydouble OR id = :mynull OR id = :myblob");
            Sqlite.bindString(statement, "mystring", "asd");
            Sqlite.bindInt(statement, "myint", 2);
            Sqlite.bindDouble(statement, "mydouble", 2.4);
            Sqlite.bindNull(statement, "mynull");
            Sqlite.bindBlob(statement, "myblob", null);

            Log.i("UnitTest", "All bind calls were successful.");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Caught unexpected error for a bind call.", ex);
        }

        try {
            statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = ? OR id = ? OR id = ? OR id = ? OR id = ?");
            Sqlite.bindStringWithIndex(statement, 1, "asd");
            Sqlite.bindIntWithIndex(statement, 2, 2);
            Sqlite.bindDoubleWithIndex(statement, 3, 2.4);
            Sqlite.bindNullWithIndex(statement, 4);
            Sqlite.bindBlobWithIndex(statement, 5, null);

            Log.i("UnitTest", "All bind with index calls were successful.");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Caught unexpected error for a bind with index call.", ex);
        }

        try {
            statement = Sqlite.prepare(db, "SELECT id FROM test WHERE id = ? OR id = ? OR id = ? OR id = ? OR id = ?");
            Sqlite.bindStringWithIndex(statement, 1, "asd");
            Sqlite.bindIntWithIndex(statement, 2, 2);
            Sqlite.bindDoubleWithIndex(statement, 3, 2.4);
            Sqlite.bindNullWithIndex(statement, 4);
            Sqlite.bindBlobWithIndex(statement, 5, null);

            Sqlite.reset(statement);

            Sqlite.bindStringWithIndex(statement, 1, "asd");
            Sqlite.bindIntWithIndex(statement, 2, 2);
            Sqlite.bindDoubleWithIndex(statement, 3, 2.4);
            Sqlite.bindNullWithIndex(statement, 4);
            Sqlite.bindBlobWithIndex(statement, 5, null);

            Log.i("UnitTest", "Can rebind after calling reset.");
            Sqlite.finalize(statement);
        }
        catch (SqliteException ex) {
            Log.e("UnitTest", "Caught unexpected error for rebindind after calling reset.", ex);
        }

        Sqlite.close(db);
        return;
    }
}