//
//  ARObject.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ARSettings.h"


@interface ARObject : UIViewController {
    
    //ARObject main components
    NSString *arTitle;
    NSString *address;
    
    int nid;
    double lat;
    double lon;
    NSNumber *distance;
    
    //OVerlay View Objects
    IBOutlet UILabel *titleL;
    IBOutlet UILabel *addressL;
    IBOutlet UILabel *distanceL;
}

@property (nonatomic, retain) NSString *arTitle;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSNumber *distance;

- (id)initWithId:(int)newNid
           title:(NSString*)newTitle
         address:(NSString*)newAddress
     coordinates:(CLLocationCoordinate2D)newCoordinates
andCurrentLocation:(CLLocationCoordinate2D)currLoc;

- (NSDictionary*)getARObjectData;

@end
