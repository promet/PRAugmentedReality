//
//  DataController.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "DataController.h"

#import "DIOSARNode.h"

@implementation DataController


#pragma mark - Main methods

-(id)init {
    self = [super init];
    if (self) {
        
        
        tries = 0;
        siteIsReachable = NO;
        
        [self startReachability];
        
        if(![self checkForDB]) {
            [self clearDB];
            if(![self checkForDB]) return 0;
        }
        
        [self fetchUpdatedARObjects];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchUpdatedARObjects)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}
-(BOOL)openDBConnection {
    
    fmdb = [FMDatabase databaseWithPath:[self getDBPath]];
    
    if ([fmdb open]) return TRUE;
    
    NSLog(@"Could not open db.");
    return FALSE;
}

-(void)alertWithTitle:(NSString*)title andMessage:(NSString*)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - DB Utilities

-(NSArray*)ar_coordinates_table_keys {
    return [NSArray arrayWithObjects:@"nid", @"lat", @"lon", nil];
}
-(NSArray*)ar_details_table_keys {
    return [NSArray arrayWithObjects:@"nid", @"title", @"address", nil];
    
}

-(NSString*)getDBPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:DB_FILE_NAME];
}
-(BOOL)createDBtables {
    NSArray *arctk = [self ar_coordinates_table_keys];
    NSArray *ardtk = [self ar_details_table_keys];
    
    if (![self openDBConnection]) return FALSE;
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ int PRIMARY KEY, %@ REAL(10), %@ REAL(10))",
                         AR_COORDINATES_TABLE,
                         [arctk objectAtIndex:0],
                         [arctk objectAtIndex:1],
                         [arctk objectAtIndex:2]]];
    
    if ([fmdb hadError]) {
        NSLog(@"error create coord: %@", fmdb.lastErrorMessage);
        return FALSE;
    }
    
    [fmdb executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ int PRIMARY KEY, %@ TEXT, %@ TEXT)",
                         AR_DETAILS_TABLE,
                         [ardtk objectAtIndex:0],
                         [ardtk objectAtIndex:1],
                         [ardtk objectAtIndex:2]]];
    
    if ([fmdb hadError]) {
        NSLog(@"error create details: %@", fmdb.lastErrorMessage);
        return FALSE;
    }
    
    [fmdb close];
    return TRUE;
}

-(void)testDBVersion {
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *db_versionPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                                stringByAppendingFormat:@"/db_version.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:db_versionPath]) {
        NSArray *db_versionArray = [NSArray arrayWithContentsOfFile:db_versionPath];
        if ([db_versionArray count] > 0 && [[db_versionArray objectAtIndex:0] isEqualToString:version]) {
            NSLog(@"DB Version is valid");
            return;
        }
    }
    [[NSFileManager defaultManager] removeItemAtPath:db_versionPath error:nil];
    [[NSArray arrayWithObject:version] writeToFile:db_versionPath atomically:YES];
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

-(NSString*)getTimestampPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:TIMESTAMP_FILE];
}
-(void)saveCurrentTimestamp {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self getTimestampPath]])
        [fileManager removeItemAtPath:[self getTimestampPath] error:nil];
    
    NSInteger timestamp = round([[NSDate date] timeIntervalSince1970]);
    [[NSString stringWithFormat:@"%d", timestamp] writeToFile:[self getTimestampPath]
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

#pragma mark - Reachability

-(void)startReachability {
    SCNetworkReachability *reachability = [[SCNetworkReachability alloc] initWithHostName:kDiosBaseUrl];
}
-(void)reachabilityDidChange:(SCNetworkStatus)status {
    switch (status)
    {
        case SCNetworkStatusReachableViaWiFi:
        case SCNetworkStatusReachableViaCellular:
            siteIsReachable = YES;
            break;
        case SCNetworkStatusNotReachable:
            siteIsReachable = NO;
            break;
        default:
            break;
    }
}



#pragma mark - Data Callbacks

-(void)passARObjectsToDelegateOnMainThread:(NSArray*)arObjects {
    [self.delegate gotNearData:arObjects];
}
-(void)getNearARObjects:(CLLocationCoordinate2D)currentLocationCoordinates {
    
    if (![self openDBConnection]) return;
    
    CLLocationDistance regionRadius = REGION_RADIUS;
    CLRegion *grRegion = [[CLRegion alloc] initCircularRegionWithCenter:currentLocationCoordinates
                                                                 radius:regionRadius identifier:@"grRegion"];
    
    NSMutableArray *arObjects = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",AR_COORDINATES_TABLE]];
    while ([rs next]) {
        
        CLLocationCoordinate2D geoobjectCoordinates = CLLocationCoordinate2DMake([[rs stringForColumn:@"lat"] floatValue],
                                                                                 [[rs stringForColumn:@"lon"] floatValue]);
        
        if (![grRegion containsCoordinate:geoobjectCoordinates]) continue;
        
        NSDictionary *detailsDict = [self getARObject:[rs stringForColumn:@"nid"]];
        if ([detailsDict count] == 0) continue;
        
        [arObjects addObject:[[ARObject alloc] initWithId:[[rs stringForColumn:@"nid"] intValue]
                                                    title:[detailsDict objectForKey:@"title"]
                                                  address:[detailsDict objectForKey:@"address"]
                                              coordinates:CLLocationCoordinate2DMake([rs doubleForColumn:@"lat"],
                                                                                     [rs doubleForColumn:@"lon"])
                                       andCurrentLocation:currentLocationCoordinates]
         ];
    }
    
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    [rs close];
    
    [grRegion release];
    
    [self performSelectorOnMainThread:@selector(passARObjectsToDelegateOnMainThread:) withObject:arObjects waitUntilDone:NO];
}
-(void)passAllARObjectsToDelegateOnMainThread:(NSDictionary*)arObjects {
    [self.delegate gotAllData:arObjects];
}


#pragma mark - Data Fetching from Drupal site

-(void)saveAllARObjects:(NSDictionary*)newARObjects {
    @try {
        if ([newARObjects count] > 0) {
            for (NSString *ar_object_nid in [newARObjects allKeys]) {
                [self saveARObject:ar_object_nid
                          withData:[newARObjects objectForKey:ar_object_nid]];
            }
            
            [self.delegate gotUpdatedData];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Got error when fetching ar_objects");
    }
    
}
-(void)fetchUpdatedARObjects {
    
    if (tries > MAX_NUMBER_OF_TRIES) {
        tries = 0;
        [self alertWithTitle:@"Unable to reach website :("
                  andMessage:@"Cannot download updated places/events..."];
        return;
    }
    if (!siteIsReachable) {
        tries++;
        [self performSelector:@selector(fetchUpdatedARObjects) withObject:nil afterDelay:1];
        return;
    }
    
    NSLog(@"Fetching Updated Places");
    [DIOSARNode getUpdatedARNodes:[self getLastUpdateTimestamp] success:^(AFHTTPRequestOperation *operation, id response) {
        [self saveAllARObjects:response];
        [self saveCurrentTimestamp];
        
    }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                              NSLog(@"got an error: %@", error.description);
                          }];
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

-(NSDictionary*)getARObject:(NSString*)nid {
    NSMutableDictionary *temporaryObjectDict = [[NSMutableDictionary alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE nid = %@", AR_DETAILS_TABLE, nid]];
    if ([rs next]) {
        [temporaryObjectDict addEntriesFromDictionary:[rs resultDict]];
    }
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    
    [rs close];
    
    return temporaryObjectDict;
}
-(void)getAllARObjects:(CLLocationCoordinate2D)coordinates {
    NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
    
    if (![self openDBConnection]) return;
    
    NSMutableDictionary *arObjects = [[NSMutableDictionary alloc] init];
    
    FMResultSet *rs = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", AR_COORDINATES_TABLE]];
    while ([rs next]) {
        NSDictionary *detailsDict = [self getARObject:[rs stringForColumn:@"nid"]];
        if ([detailsDict count] == 0) continue;
        
        [arObjects setObject:[[ARObject alloc] initWithId:[[rs stringForColumn:@"nid"] intValue]
                                                    title:[detailsDict objectForKey:@"title"]
                                                  address:[detailsDict objectForKey:@"address"]
                                              coordinates:CLLocationCoordinate2DMake([rs doubleForColumn:@"lat"],
                                                                                     [rs doubleForColumn:@"lon"])
                                       andCurrentLocation:coordinates]
                      forKey:[rs stringForColumn:@"nid"]
         ];
    }
    
    if ([fmdb hadError]) NSLog(@"error: %@", fmdb.lastError);
    [rs close];
    
    [self performSelectorOnMainThread:@selector(passAllARObjectsToDelegateOnMainThread:) withObject:arObjects waitUntilDone:NO];
    
    [subPool release];
}

-(NSString*)escapeApostrophesFrom:(NSString*)inputString {
    return [inputString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}
-(NSString*)removeCommasFrom:(NSString*)inputString {
    return [inputString stringByReplacingOccurrencesOfString:@"," withString:@""];
}
-(NSString*)buildAddress:(NSDictionary*)address {
    NSMutableString *validAddress = [address objectForKey:@"thoroughfare"];
    
    if ([(NSString*)[address objectForKey:@"premise"] length] > 0) {
        [validAddress appendFormat:@", %@",[address objectForKey:@"premise"]];
    }
    
    return [self removeCommasFrom:validAddress];
}

-(void)saveARObject:(NSString*)nid withData:(NSDictionary*)data {
    if(![self openDBConnection]) NSLog(@"No go!");
    
    // -- DELETE the AR_Object if it exists -- //
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_COORDINATES_TABLE, nid]];
    [fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE nid='%@'", AR_DETAILS_TABLE, nid]];
    
    // -- Fill in arrays -- //
    NSArray *coord_keys_array = [self ar_coordinates_table_keys];
    NSArray *details_keys_array = [self ar_details_table_keys];
    
    // -- Coordinates data -- //
    NSString *coord_keys = [NSString stringWithFormat:@"%@, %@, %@",
                            [coord_keys_array objectAtIndex:0],
                            [coord_keys_array objectAtIndex:1],
                            [coord_keys_array objectAtIndex:2]];
    
    NSString *coord_values = [NSString stringWithFormat:@"%@, %@, %@",
                              [data objectForKey:@"nid"],
                              [[data objectForKey:@"coordinates"] objectForKey:@"lat"],
                              [[data objectForKey:@"coordinates"] objectForKey:@"lon"]];
    
    // -- Details data -- //
    NSString *details_keys = [NSString stringWithFormat:@"%@, %@, %@",
                              [details_keys_array objectAtIndex:0],
                              [details_keys_array objectAtIndex:1],
                              [details_keys_array objectAtIndex:2]];
    
    NSString *details_values = [NSString stringWithFormat:@"%@, '%@', '%@'",
                                [data objectForKey:@"nid"],
                                [self escapeApostrophesFrom:[data objectForKey:@"title"]],
                                [self escapeApostrophesFrom:[self buildAddress:[data objectForKey:@"address"]]]];
    
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
        return;
    }
    
    [fmdb executeUpdate:details_query];
    if ([fmdb hadError]) {
        NSLog(@"error on details insert: %@", fmdb.lastErrorMessage);
        [fmdb close];
        
        [self removeRequest:nid];
        return;
    }
    
    [fmdb close];
}


@end
