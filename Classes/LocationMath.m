//
//  LocationMath.m
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

#import "LocationMath.h"


@implementation LocationMath

static LocationMath *_sharedCalculator = nil;
static dispatch_once_t onceToken;

@synthesize location;


+(id)sharedExpert
{
    @synchronized([LocationMath class]) {
        dispatch_once(&onceToken, ^{
            _sharedCalculator = [[self alloc] init];
        });
    }
    
    return _sharedCalculator;
}
-(id)init
{
    self = [super init];
    if (self) {        
        motionManager = [[CMMotionManager alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDelegate:self];
    }
    return self;
}


# pragma mark - LocationManager


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    currentHeading =  fmod(newHeading.trueHeading, 360.0);
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed to update Loc: %@", error);
}

-(void)pollAccellerometerForVerticalPosition
{
    CMAcceleration acceleration = motionManager.accelerometerData.acceleration;
    
    rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    
	if (rollingZ > 0.0)      currentInclination = inc_avg(atan(rollingX / rollingZ) + M_PI / 2.0);
	else if (rollingZ < 0.0) currentInclination = inc_avg(atan(rollingX / rollingZ) - M_PI / 2.0);
	else if (rollingX < 0)   currentInclination = inc_avg(M_PI/2.0);
	else if (rollingX >= 0)  currentInclination = inc_avg(3 * M_PI/2.0);
}

# pragma mark - Accellerometer

-(void)startTrackingWithLocation:(CLLocationCoordinate2D)newLocation andSize:(CGSize)deviceScreenSize
{
    deviceViewHeight = deviceScreenSize.height;
    
    [locationManager startUpdatingHeading];
    [motionManager startAccelerometerUpdates];
    
    location = CLLocationCoordinate2DMake(newLocation.latitude, newLocation.longitude);

    if (accelTimer) accelTimer = nil;
    accelTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE
                                                  target:self
                                                selector:@selector(pollAccellerometerForVerticalPosition)
                                                userInfo:nil
                                                 repeats:YES];
}


# pragma mark - Callback functions

-(CGRect)getCurrentFramePosition
{
    float y_pos = currentInclination*VERTICAL_SENS;
    float x_pos = X_CENTER+(0-currentHeading)*HORIZ_SENS;
    
    return CGRectMake(x_pos, y_pos+60, OVERLAY_VIEW_WIDTH, deviceViewHeight);
}
-(int)getCurrentHeading
{
    return (int)currentHeading;
}
-(int)getARObjectXPosition:(ARObject*)arObject
{
    CLLocationCoordinate2D coordinates;
    coordinates.latitude        = [[arObject getARObjectData][@"latitude"] doubleValue];
    coordinates.longitude       = [[arObject getARObjectData][@"longitude"] doubleValue];
    
    double latitudeDistance     = max(coordinates.latitude, location.latitude) - min(coordinates.latitude, location.latitude);
    double longitudeDistance    = max(coordinates.longitude, location.longitude) - min(coordinates.longitude, location.longitude);
    
    int x_position = DEGREES(atanf(longitudeDistance/(latitudeDistance*lat_over_lon)));
    
    if ((coordinates.latitude < location.latitude) && (coordinates.longitude > location.longitude))
        x_position = 180-x_position;
    
    else if ((coordinates.latitude < location.latitude) && (coordinates.longitude < location.longitude))
        x_position += 180;
    
    else if ((coordinates.latitude > location.latitude) && (coordinates.longitude < location.longitude))
        x_position += 270;
    
    return x_position*HORIZ_SENS;
}

@end
