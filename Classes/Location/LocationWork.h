//
//  LocationWork.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#import "ARObject.h"

@class LocationWork;

@protocol LocationWorkDelegate
- (void)gotPreciseLocation:(CLLocationCoordinate2D)preciseLocation;
@end


@interface LocationWork : NSObject <CLLocationManagerDelegate, UIAccelerometerDelegate> {
    
    // Main managers
    CLLocationManager * locationManager;
    UIAccelerometer *accelerometer;
    
    // Major variables   
    float currentHeading;
    float currentInclination;

    double currentLat;
    double currentLon;
    
    // Others
    float rollingZ;
    float rollingX;
    
    BOOL gotPreciseEnoughLocation;
    
    float deviceViewHeight;
}

@property (assign, nonatomic) id <LocationWorkDelegate> delegate;

-(id)init;
-(void)startAR:(CGSize)deviceScreenSize;

-(CGRect)getCurrentFramePosition;
-(int)getARObjectXPosition:(ARObject*)arObject;

@end
