//
//  LocationWork.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "LocationWork.h"


@implementation LocationWork


-(id)init {
    self = [super init];
    if (self) {
        gotPreciseEnoughLocation = NO;
        
        [self setupLocationManager];
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}


# pragma mark - LocationManager

-(void)setupLocationManager {
    if (locationManager == nil){
		locationManager = [[CLLocationManager alloc]init];
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.delegate = self;
	}
    
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    currentHeading =  fmod(newHeading.trueHeading, 360.0);
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (!gotPreciseEnoughLocation && newLocation.horizontalAccuracy < MIN_LOCATION_ACCURACY) {
        
        gotPreciseEnoughLocation = YES;
        [locationManager stopUpdatingLocation];
        
        [self.delegate gotPreciseLocation:newLocation.coordinate];
    }
    
    if (newLocation.horizontalAccuracy < MIN_LOCATION_ACCURACY) {
        currentLat = newLocation.coordinate.latitude;
        currentLon = newLocation.coordinate.longitude;
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to update Loc: %@", error);
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) [self setupLocationManager];
}


# pragma mark - Accellerometer

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    
	if (rollingZ > 0.0)      currentInclination = inc_avg(atan(rollingX / rollingZ) + M_PI / 2.0);
	else if (rollingZ < 0.0) currentInclination = inc_avg(atan(rollingX / rollingZ) - M_PI / 2.0);
	else if (rollingX < 0)   currentInclination = inc_avg(M_PI/2.0);
	else if (rollingX >= 0)  currentInclination = inc_avg(3 * M_PI/2.0);
}

-(void)startAR:(CGSize)deviceScreenSize {
    
    [locationManager startUpdatingHeading];
    
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = 0.01;
    [accelerometer setDelegate:self];
    
    deviceViewHeight = deviceScreenSize.height;
}


# pragma mark - Callback functions

-(CGRect)getCurrentFramePosition {
    float y_pos = currentInclination*VERTICAL_SENS;
    float x_pos = X_CENTER+(0-currentHeading)*HORIZ_SENS;
    
    return CGRectMake(x_pos, y_pos+60, OVERLAY_VIEW_WIDTH, deviceViewHeight);
}
-(int)getARObjectXPosition:(ARObject*)arObject {
    CLLocationCoordinate2D coordinates;
    coordinates.latitude        = [[[arObject getARObjectData] objectForKey:@"latitude"] doubleValue];
    coordinates.longitude       = [[[arObject getARObjectData] objectForKey:@"longitude"] doubleValue];
    
    double latitudeDistance     = max(coordinates.latitude, currentLat) - min(coordinates.latitude, currentLat);
    double longitudeDistance    = max(coordinates.longitude, currentLon) - min(coordinates.longitude, currentLon);
    
    int x_position = DEGREES(atanf(longitudeDistance/(latitudeDistance*lat_over_lon)));
    
    if ((coordinates.latitude < currentLat) && (coordinates.longitude > currentLon))
        x_position = 180-x_position;
    
    else if ((coordinates.latitude < currentLat) && (coordinates.longitude < currentLon))
        x_position += 180;
    
    else if ((coordinates.latitude > currentLat) && (coordinates.longitude < currentLon))
        x_position += 270;
    
    return x_position*HORIZ_SENS;
}

@end
