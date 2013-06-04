//
//  DBController.h
//  Pods
//
//  Created by ANDREW KUCHARSKI on 5/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

@interface DBController : NSObject {
    FMDatabase *fmdb;
}

-(NSArray*)getARObjectsNear:(CLLocation*)location;
-(NSArray*)getAllARObjectsAndSetupWithLoc:(CLLocation*)location;

-(BOOL)saveARObject:(NSString*)nid withData:(NSDictionary*)data;

-(void)saveCurrentTimestamp;
-(NSString*)getLastUpdateTimestamp;

@end
