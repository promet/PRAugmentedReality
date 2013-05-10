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
        
        distance = [[NSNumber alloc] initWithFloat:[self calculateDistanceFrom:currLoc]];
        
        [self.view setTag:newNid];
    }
    return self;
}

-(float)calculateDistanceFrom:(CLLocationCoordinate2D)currentLoc {
    
    double latitudeDistance =    max(lat, currentLoc.latitude) - min(lat, currentLoc.latitude);
    double longitudeDistance  =  max(lon, currentLoc.longitude) - min(lon, currentLoc.longitude);
    
    return (sqrt(pow(latitudeDistance*lat_over_lon,2) + pow(longitudeDistance, 2))) * meterToMiles;
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
    
    if (distance.floatValue < MAXIMUM_DISTANCE) [distanceL setText:[NSString stringWithFormat:@"%.2f mi", distance.floatValue]];
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
