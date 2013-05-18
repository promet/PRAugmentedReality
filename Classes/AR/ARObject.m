//
//  ARObject.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "ARObject.h"


@interface ARObject ()

@end


@implementation ARObject

@synthesize arTitle, address, distance;

- (id)initWithId:(int)newNid
           title:(NSString*)newTitle
         address:(NSString*)newAddress
     coordinates:(CLLocationCoordinate2D)newCoordinates
andCurrentLocation:(CLLocationCoordinate2D)currLoc {
    
    self = [super init];
    if (self) {
        nid = newNid;
        
        arTitle = [[NSString alloc] initWithString:newTitle];
        address = [[NSString alloc] initWithString:newAddress];
        
        lat = newCoordinates.latitude;
        lon = newCoordinates.longitude;
        
        distance = [[NSNumber alloc] initWithDouble:[self calculateDistanceFrom:currLoc]];
        
        [self.view setTag:newNid];
    }
    return self;
}

-(double)calculateDistanceFrom:(CLLocationCoordinate2D)user_loc_coord {
    
    CLLocationCoordinate2D object_loc_coord = CLLocationCoordinate2DMake(lat, lon);
    
    CLLocation *object_location = [[[CLLocation alloc] initWithLatitude:object_loc_coord.latitude
                                                              longitude:object_loc_coord.longitude]
                                   autorelease];
    CLLocation *user_location = [[[CLLocation alloc] initWithLatitude:user_loc_coord.latitude
                                                           longitude:user_loc_coord.longitude]
                                 autorelease];
    
    return [object_location distanceFromLocation:user_location]*METERS_TO_MILES;
}

- (NSDictionary*)getARObjectData {
    NSArray *keys = [NSArray arrayWithObjects:@"id",@"title", @"address", @"latitude", @"longitude", @"distance", nil];
    
    NSArray *values = [NSArray arrayWithObjects:
                       [NSNumber numberWithInt:nid],
                       arTitle,
                       address,
                       [NSNumber numberWithDouble:lat],
                       [NSNumber numberWithDouble:lon],
                       distance,
                       nil];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [titleL setText:arTitle];
    [addressL setText:address];
    
    NSLog(@"distance: %.2f", distance.doubleValue);
    
    if (distance.doubleValue < MAXIMUM_DISTANCE) [distanceL setText:[NSString stringWithFormat:@"%.2f mi", distance.doubleValue]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
    
    [arTitle release];
    [address release];
    [distance release];
}

@end
