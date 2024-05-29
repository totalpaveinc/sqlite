//
//  main.m
//  sqlitetestapp
//
//  Created by Norman Breau on 2023-08-24.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <sqlite/sqlite3.h>
#import <sqlite/TPISQLiteUtilities.h>

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    
    // Ensure path exists
    
    NSString* location = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    location = [location stringByAppendingPathComponent:@"nosync"];
    NSLog(@"Location (%@)", location);
    if (![[NSFileManager defaultManager] fileExistsAtPath: location])
    {
        NSError* error;
        if([[NSFileManager defaultManager] createDirectoryAtPath: location withIntermediateDirectories:NO attributes: nil error:&error]) {
            NSLog(@"bob");
        }
        else {
            NSLog(@"not bob");
            NSLog(@"Error: %@",[error localizedDescription]);
        }
    }
    
    printf("\nVersion: %s:", SQLITE_VERSION);
    sqlite3* db;
    // Prepare full path
    location = [location stringByAppendingPathComponent:@"bob"];
    location = [location stringByAppendingPathExtension:@"db"];
    printf("\nLocation (%s) ", [location UTF8String]);
    printf("\nopen %d ", sqlite3_open_v2([location UTF8String], &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_URI, NULL));
    sqlite3_stmt* query;
    sqlite3_stmt* querya;
    sqlite3_stmt* queryb;
    
    // Note code 101 === DONE, it's a successful code.
    
    const char* qstr = "CREATE TABLE IF NOT EXISTS test ( id INTEGER NOT NULL, name TEXT NOT NULL, height REAL, data BLOB)";
    sqlite3_prepare_v2(db, qstr, strlen(qstr), &query, NULL);
    printf("\ncreate %d ", sqlite3_step(query));
    sqlite3_finalize(query);
    
    const char* that = "INSERT INTO test VALUES (:id, :name, :height, :data)";
    sqlite3_prepare_v2(db, that, strlen(that), &querya, NULL);
    int index = [TPISQLiteUtilities lookupVariableIndex:querya var:@"id"];
    sqlite3_bind_int(querya, index, 1);
    index = [TPISQLiteUtilities lookupVariableIndex:querya var:@"name"];
    sqlite3_bind_text(querya, index, "bob", 4, NULL);
    index = [TPISQLiteUtilities lookupVariableIndex:querya var:@"height"];
    sqlite3_bind_double(querya, index, 34.2);
    index = [TPISQLiteUtilities lookupVariableIndex:querya var:@"data"];
    sqlite3_bind_blob(querya, index, NULL, 0, NULL);
    
    printf("\ninsert %d ", sqlite3_step(querya));
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

    printf("\nselect %d ", code);
    sqlite3_finalize(queryb);

    
    //Calling step after finalize should return SQLITE_MISUSE but it's ultimately undefined behaviour.
    //So anything can happen. During my tests, it was hard-crashing with an uncatchable error.
    //While creating a preventative system is probably possible, we've decided it would be high-cost-low-reward.
    //Error cases that could run in to this is not something that randomly happens because of runtime data.
    //The code path is literally just written incorrectly.
    //As such we have no way of gracefully handling this error path and we are simply commenting out the try-catch block.
    //const char* test = "SELECT * FROM test;";
    //sqlite3_prepare_v2(db, notthat, strlen(test), &queryb, NULL);
    //sqlite3_finalize(queryb);
    //int a = sqlite3_step(queryb);


    sqlite3_close(db);
    
    printf("Tests completed.\n");

    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

