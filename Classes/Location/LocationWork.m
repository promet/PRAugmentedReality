//
//  LocationWork.m
//  PrometAR
//
// Created by Geoffroy Lesage on 4/24/13.
// Copyright (c) 2013 Promet Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "LocationWork.h"


@implementation LocationWork

@synthesize gotPreciseEnoughLocation;
@synthesize currentLat, currentLon;


-(id)init {
    self = [super init];
    if (self) {
        gotPreciseEnoughLocation = NO;
        
        [self setupLocationManager];
    }
    return self;
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
    if (newLocation.horizontalAccuracy < MIN_LOCATION_ACCURACY) {
        gotPreciseEnoughLocation = YES;
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
