//
//  DataController.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ARObject.h"

#import "SCNetworkReachability.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"


@class DataController;

@protocol ARObjectsDataDelegate
- (void)gotNearData:(NSArray*)arObjects;
- (void)gotAllData:(NSDictionary*)arObjects;

- (void)gotUpdatedData;

@end

@interface DataController : NSObject <SCNetworkReachabilityDelegate> {
    FMDatabase *fmdb;
    
    // -- Reachability -- //
    BOOL siteIsReachable;
    int tries;
}

@property (assign, nonatomic) id <ARObjectsDataDelegate> delegate;

-(void)getNearARObjects:(CLLocationCoordinate2D)coordinates;
-(void)fetchUpdatedARObjects;

-(void)getAllARObjects:(CLLocationCoordinate2D)coordinates;

@end