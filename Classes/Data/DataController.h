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

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"


@class DataController;

@protocol ARObjectsDataDelegate
- (void)gotNearARData:(NSArray*)arObjects;
- (void)gotAllARData:(NSDictionary*)arObjects;

- (void)gotUpdatedARNearData:(NSArray*)arObjects;
@end

@interface DataController : NSObject {
    FMDatabase *fmdb;
    CLLocationCoordinate2D currentLocationCoord;
}

@property (assign, nonatomic) id <ARObjectsDataDelegate> delegate;

-(void)getGeoObjectsNear:(CLLocationCoordinate2D)coordinates forUpdate:(BOOL)forUpdate;
-(void)fetchUpdatedARObjects;

-(void)getAllARObjects;

@end