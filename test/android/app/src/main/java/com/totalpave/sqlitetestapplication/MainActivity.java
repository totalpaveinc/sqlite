package com.totalpave.sqlitetestapplication;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;

import com.totalpave.sqlite3.Statement;
import com.totalpave.sqlite3.Sqlite;

import java.io.File;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        File dataDirectory = getApplicationContext().getFilesDir();
        String dbPath = dataDirectory.getAbsolutePath() + "/test.db";

       long db = Sqlite.open(dbPath, Sqlite.CREATE | Sqlite.READ_WRITE);
       long statement = Sqlite.prepare(db, "CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL, name TEXT NOT NULL, height REAL, data BLOB)");
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
                Log.i("Sqlite Test", msg);
            }
            else if (result == Statement.DONE) {
                // Exit without error
                break;
            }
            else {
                Log.e("SQLite Test", "Statement error: " + result);
                break;
            }
        }

        Sqlite.finalize(statement);

       Sqlite.close(db);
   }
}