//
//  main.m
//  sqlitetest
//
//  Created by Tyler Breau on 2022-09-01.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#include <sqlite3.h>

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    
    // Ensure path exists
    
    NSString* location = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    location = [location stringByAppendingPathComponent:@"nosync"];
    NSLog(@"%@", location);
    if (![[NSFileManager defaultManager] fileExistsAtPath: location])
    {
        NSError* error;
        if([[NSFileManager defaultManager] createDirectoryAtPath: location withIntermediateDirectories:NO attributes: nil error:&error]) {
            printf("bob");
        }
        else {
            printf("not bob");
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    
    printf("Version: %s:", SQLITE_VERSION);
    sqlite3* db;
    // Prepare full path
    location = [location stringByAppendingPathComponent:@"bob"];
    location = [location stringByAppendingPathExtension:@"db"];
    printf("%s ", [location UTF8String]);
    printf("open %d ", sqlite3_open_v2([location UTF8String], &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_URI, NULL));
    sqlite3_stmt* query;
    sqlite3_stmt* querya;
    sqlite3_stmt* queryb;
    
    // Note code 101 === DONE, it's a successful code.
    
    const char* qstr = "CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL, name TEXT NOT NULL, height REAL, data BLOB)";
    sqlite3_prepare_v2(db, qstr, strlen(qstr), &query, NULL);
    printf("create %d ", sqlite3_step(query));
    sqlite3_finalize(query);
    
    const char* that = "INSERT INTO test VALUES (:id, :name, :height, :data)";
    sqlite3_prepare_v2(db, that, strlen(that), &querya, NULL);
    int index = sqlite3_bind_parameter_index(querya, ":id");
    sqlite3_bind_int(querya, index, 1);
    index = sqlite3_bind_parameter_index(querya, ":name");
    sqlite3_bind_text(querya, index, "bob", 4, NULL);
    index = sqlite3_bind_parameter_index(querya, ":height");
    sqlite3_bind_double(querya, index, 34.2);
    index = sqlite3_bind_parameter_index(querya, ":data");
    sqlite3_bind_blob(querya, index, NULL, 0, NULL);
    
    printf("insert %d ", sqlite3_step(querya));
    sqlite3_finalize(querya);

    const char* notthat = "SELECT * FROM test;";
    sqlite3_prepare_v2(db, notthat, strlen(notthat), &queryb, NULL);

    int code = sqlite3_step(queryb);
    while (code == SQLITE_ROW) {
        printf(
            "\nid: %d \n name: %s \n height: %f \n data: %x",
            sqlite3_column_int(queryb, 0),
            sqlite3_column_text(queryb, 1),
            sqlite3_column_double(queryb, 2),
            sqlite3_column_blob(queryb, 3)
        );
        
        code = sqlite3_step(queryb);
    }

    if (code != SQLITE_OK) {
        //error
    }

    printf("select %d ", code);
    sqlite3_finalize(queryb);

    sqlite3_close(db);

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}