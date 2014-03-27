//
//  DBController.m
//  Pods
//
//  Created by ANDREW KUCHARSKI on 5/22/13.
//
//

#import "DBController.h"

#define DB_FILE_NAME            @"db.sqlite"

#define AR_COORDINATES_TABLE    @"arct"
#define AR_DETAILS_TABLE        @"ardt"

#define TIMESTAMP_FILE          @"timestamp.time"

#define REGION_RADIUS           800 // meters


@implementation DBController


#pragma mark - Main Methods

-(id)init {
    self = [super init];
    if (self) {
        
        if(![self checkForDB]) {
            [self clearDB];
            if(![self checkForDB]) return 0;
        }
    }
    return self;
}


#pragma mark - Timestamp check

-(NSString*)getTimestampPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:TIMESTAMP_FILE];
}
-(void)saveCurrentTimestamp {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self getTimestampPath]])
        [fileManager removeItemAtPath:[self getTimestampPath] error:nil];
    
    NSInteger timestamp = round([[NSDate date] timeIntervalSince1970]);
    [[NSString stringWithFormat:@"%ld", (long)timestamp] writeToFile:[self getTimestampPath]
                                                   atomically:YES
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
}
-(NSString*)getLastUpdateTimestamp {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self getTimestampPath]]) {
        return [NSString stringWithContentsOfFile:[self getTimestampPath]
                                         encoding:NSUTF8StringEncoding
                                            error:nil];
    }
    
    return @"0";
}


#pragma mark - DB Utilities

-(BOOL)openDBConnection {
    
    fmdb = [FMDatabase databaseWithPath:[self getDBPath]];
    
    if ([fmdb open]) return TRUE;
    
    NSLog(@"Could not open db.");
    return FALSE;
}

-(NSArray*)ar_coordinates_table_keys {
    return @[@"nid", @"lat", @"lon"];
}
-(NSArray*)ar_details_table_keys {
    return @[@"nid", @"title", @"address"];
    
}

-(NSString*)getDBPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:DB_FILE_NAME];
}
-(BOOL)createDBtables {
    NSArray *arctk = [self ar_coordinates_table_keys];
    NSArray *ardtk = [self ar_details_table_keys];
    
    if (![self openDBConnection]) return FALSE;
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ int PRIMARY KEY, %@ REAL(10), %@ REAL(10))",
                         AR_COORDINATES_TABLE,
                         arctk[0],
                         arctk[1],
                         arctk[2]]];
    
    if ([fmdb hadError]) {
        NSLog(@"error create coord: %@", fmdb.lastErrorMessage);
        return FALSE;
    }
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ int PRIMARY KEY, %@ TEXT, %@ TEXT)",
                         AR_DETAILS_TABLE,
                         ardtk[0],
                         ardtk[1],
                         ardtk[2]]];
    
    if ([fmdb hadError]) {
        NSLog(@"error create details: %@", fmdb.lastErrorMessage);
        return FALSE;
    }
    
    [fmdb close];
    return TRUE;
}

-(void)testDBVersion {
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *db_versionPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
                                stringByAppendingFormat:@"/db_version.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:db_versionPath]) {
        NSArray *db_versionArray = [NSArray arrayWithContentsOfFile:db_versionPath];
        if ([db_versionArray count] > 0 && [db_versionArray[0] isEqualToString:version]) {
            NSLog(@"DB Version is valid");
            return;
        }
    }
    [[NSFileManager defaultManager] removeItemAtPath:db_versionPath error:nil];
    [@[version] writeToFile:db_versionPath atomically:YES];
    [self clearDB];
    
    NSLog(@"RESET DB");
}

-(BOOL)doTablesExist {
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT COUNT() as count \
                                          FROM sqlite_master \
                                          WHERE type='table' AND name='%@'",
                                          AR_COORDINATES_TABLE]];
    
    
    if ([rs next] && [rs intForColumn:@"count"] == 1) {
        [rs close];
        [fmdb close];
        
        return TRUE;
    }
    
    [rs close];
    
    return FALSE;
}
-(BOOL)checkForDB {
    [self testDBVersion];
    
    if (![self openDBConnection]) return FALSE;
    
    if (![self doTablesExist]) {
        [fmdb close];
        return FALSE;
    }
    
    [fmdb close];
    return TRUE;
}
-(void)clearDB {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self getDBPath] error:nil];
    [fileManager removeItemAtPath:[self getTimestampPath] error:nil];
    
    [self createDBtables];
}


#pragma mark - Database Data CRUD

-(void)removeRequest:(NSString*)nid {
    [self openDBConnection];
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_COORDINATES_TABLE, nid]];
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_DETAILS_TABLE, nid]];
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    
    [fmdb close];
}

-(NSDictionary*)getARObjectDetails:(NSString*)nid {
    NSMutableDictionary *temporaryObjectDict = [[NSMutableDictionary alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE nid = %@", AR_DETAILS_TABLE, nid]];
    if ([rs next]) {
        [temporaryObjectDict addEntriesFromDictionary:[rs resultDictionary]];
    }
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    
    [rs close];
    
    return temporaryObjectDict;
}

-(NSString*)escapeApostrophesFrom:(NSString*)inputString {
    return [inputString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}
-(NSString*)removeCommasFrom:(NSString*)inputString {
    return [inputString stringByReplacingOccurrencesOfString:@"," withString:@""];
}
-(NSString*)buildAddress:(NSDictionary*)address {
    NSMutableString *validAddress = address[@"thoroughfare"];
    
    if ([(NSString*)address[@"premise"] length] > 0) {
        [validAddress appendFormat:@", %@",address[@"premise"]];
    }
    
    return [self removeCommasFrom:validAddress];
}


#pragma mark - Data callbacks

-(NSArray*)getARObjectsNear:(CLLocation*)location {
    if (!location || location == nil) return nil;
    if (![self openDBConnection]) return nil;
    
    CLLocationDistance regionRadius = REGION_RADIUS;
    CLRegion *grRegion = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate
                                                                 radius:regionRadius identifier:@"grRegion"];
    
    NSMutableArray *arObjects = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 10",AR_COORDINATES_TABLE]];
    while ([rs next]) {
        
        CLLocationCoordinate2D geoobjectCoordinates = CLLocationCoordinate2DMake([[rs stringForColumn:@"lat"] floatValue],
                                                                                 [[rs stringForColumn:@"lon"] floatValue]);
        
        if (![grRegion containsCoordinate:geoobjectCoordinates]) continue;
        
        NSDictionary *detailsDict = [self getARObjectDetails:[rs stringForColumn:@"nid"]];
        if ([detailsDict count] == 0) continue;
        
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:detailsDict];
        tempDict[@"lat"] = [rs stringForColumn:@"lat"];
        tempDict[@"lon"] = [rs stringForColumn:@"lon"];
        
        [arObjects addObject:tempDict];
    }
    
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    [rs close];
    
    
    return arObjects;
}
-(NSArray*)getAllARObjectsAndSetupWithLoc:(CLLocation*)location {
    if (!location || location == nil) return nil;
    if (![self openDBConnection]) return nil;
    
    NSMutableArray *arObjects = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",AR_COORDINATES_TABLE]];
    while ([rs next]) {
        
        NSDictionary *detailsDict = [self getARObjectDetails:[rs stringForColumn:@"nid"]];
        if ([detailsDict count] == 0) continue;
        
        [arObjects addObject:detailsDict];
    }
    
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    [rs close];
    
    return arObjects;
}

-(BOOL)saveARObject:(NSString*)nid withData:(NSDictionary*)data {
    if(![self openDBConnection]) return FALSE;
    
    // -- DELETE the AR_Object if it exists -- //
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_COORDINATES_TABLE, nid]];
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_DETAILS_TABLE, nid]];
    
    // -- Fill in arrays -- //
    NSArray *coord_keys_array = [self ar_coordinates_table_keys];
    NSArray *details_keys_array = [self ar_details_table_keys];
    
    // -- Coordinates data -- //
    NSString *coord_keys = [NSString stringWithFormat:@"%@, %@, %@",
                            coord_keys_array[0],
                            coord_keys_array[1],
                            coord_keys_array[2]];
    
    NSString *coord_values = [NSString stringWithFormat:@"%@, %@, %@",
                              data[@"nid"],
                              data[@"coordinates"][@"lat"],
                              data[@"coordinates"][@"lon"]];
    
    // -- Details data -- //
    NSString *details_keys = [NSString stringWithFormat:@"%@, %@, %@",
                              details_keys_array[0],
                              details_keys_array[1],
                              details_keys_array[2]];
    
    NSString *details_values = [NSString stringWithFormat:@"%@, '%@', '%@'",
                                data[@"nid"],
                                [self escapeApostrophesFrom:data[@"title"]],
                                [self escapeApostrophesFrom:[self buildAddress:data[@"address"]]]];
    
    // -- Build queries -- //
    NSString *coord_query = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",
                             AR_COORDINATES_TABLE,
                             coord_keys,
                             coord_values];
    
    NSString *details_query = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",
                               AR_DETAILS_TABLE,
                               details_keys,
                               details_values];
    
    // -- Execute queries -- //
    [fmdb executeUpdate:coord_query];
    if ([fmdb hadError]) {
        NSLog(@"error on coord insert: %@", fmdb.lastErrorMessage);
        [fmdb close];
        return FALSE;
    }
    
    [fmdb executeUpdate:details_query];
    if ([fmdb hadError]) {
        NSLog(@"error on details insert: %@", fmdb.lastErrorMessage);
        [fmdb close];
        
        [self removeRequest:nid];
        return FALSE;
    }
    
    [fmdb close];
    
    return TRUE;
}

@end
