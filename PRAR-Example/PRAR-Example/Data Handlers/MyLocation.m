//
//  MyLocation.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 6/28/12.
//  Copyright (c) 2012 Promet Solutions. All rights reserved.
//

#import "MyLocation.h"

@implementation MyLocation

@synthesize nid;

@synthesize name = _name;
@synthesize coordinate = _coordinate;

@synthesize arObject = _arObject;


- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate andId:(NSInteger)newId {
    if ((self = [super init])) {
        nid = newId;
        
        _name = [name copy];
        _coordinate = coordinate;
    }
    return self;
}

- (id)initWithOverlay:(ARObject*)newARObject {
    if ((self = [super init])) {
        _arObject = newARObject;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown place";
    else
        return _name;
}

@end
