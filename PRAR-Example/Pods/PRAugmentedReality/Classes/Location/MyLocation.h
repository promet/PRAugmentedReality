//
//  MyLocation.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 6/28/12.
//  Copyright (c) 2012 Promet Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "ARObject.h"

@interface MyLocation : NSObject <MKAnnotation> {
    NSInteger nid;
    NSString *_name;
    CLLocationCoordinate2D _coordinate;
    
    ARObject *_arObject;
}

@property (nonatomic) NSInteger nid;

@property (copy) NSString *name;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, readonly) ARObject *arObject;


- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate andId:(NSInteger)newId;
- (id)initWithOverlay:(ARObject*)newARObject;

@end