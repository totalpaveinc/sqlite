//
//  sqlite.h
//  sqlite
//
//  Created by Norman Breau on 2023-08-24.
//

#import <Foundation/Foundation.h>

//! Project version number for sqlite3.
FOUNDATION_EXPORT double sqlite3VersionNumber;

//! Project version string for sqlite3.
FOUNDATION_EXPORT const unsigned char sqlite3VersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <sqlite3/PublicHeader.h>

// The pure SQLite headers
#import <sqlite/sqlite3.h>
#import <sqlite/sqlite3rc.h>

#import <sqlite/TPISQLiteUtilities.h>
