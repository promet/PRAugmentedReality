//
//  DataController.m
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

#import "DataController.h"

#import "DIOSARNode.h"

#define MAX_NUMBER_OF_TRIES     5 

@implementation DataController


#pragma mark - Main methods

-(id)init {
    self = [super init];
    if (self) {
        
        tries = 0;
        fetching = NO;
        
        [self startReachability];
        
        dbController = [[DBController alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchUpdatedARObjects)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

-(void)alertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Reachability

-(void)startReachability {
    reachability = [[SCNetworkReachability alloc] initWithHostName:@"www.google.com"];
    reachability.delegate = self;
}
-(void)reachabilityDidChange:(SCNetworkStatus)status {
    
    switch (status)
    {
        case SCNetworkStatusReachableViaWiFi:
        case SCNetworkStatusReachableViaCellular:
            siteIsReachable = YES;
            break;
            
        case SCNetworkStatusNotReachable:
            siteIsReachable = NO;
            break;
            
        default:
            break;
    }
}


#pragma mark - Data Callbacks

-(void)passARObjectsToDelegateOnMainThread:(NSArray*)arObjects {
    [self.delegate gotNearData:arObjects];
}
-(void)passAllARObjectsToDelegateOnMainThread:(NSArray*)arObjects {
    [self.delegate gotAllData:arObjects];
}

-(void)getNearARObjects_IN_BACKGROUND:(CLLocation*)location {
    NSArray *arObjects = [dbController getARObjectsNear:location];
    if (!arObjects || arObjects == nil) return;
    
    [self.delegate gotNearData:arObjects];
}
-(void)getNearARObjects:(CLLocationCoordinate2D)coordinates {
    [self performSelectorInBackground:@selector(getNearARObjects_IN_BACKGROUND:)
                           withObject:[[CLLocation alloc] initWithLatitude:coordinates.latitude
                                                                 longitude:coordinates.longitude]];
}

-(void)getAllARObjects_IN_BACKGROUND:(CLLocation*)location {
    NSArray *arObjects = [dbController getAllARObjectsAndSetupWithLoc:location];
    if (!arObjects || arObjects == nil) return;
    
    [self.delegate gotAllData:arObjects];
}
-(void)getAllARObjects:(CLLocationCoordinate2D)coordinates {
    [self performSelectorInBackground:@selector(getAllARObjects_IN_BACKGROUND:)
                           withObject:[[CLLocation alloc] initWithLatitude:coordinates.latitude
                                                                 longitude:coordinates.longitude]];
}


#pragma mark - Data Fetching from Drupal site

-(void)saveAllARObjects:(NSDictionary*)newARObjects {
    @try {
        if ([newARObjects count] > 0) {
            for (NSString *ar_object_nid in newARObjects.allKeys) {
                NSDictionary *ar_obj = newARObjects[ar_object_nid];
                if (ar_obj[@"coordinates"][@"lat"] == [NSNull null]) continue;
                if ([ar_obj[@"coordinates"][@"lat"] isEqualToString:@"<null>"]) continue;
                
                [dbController saveARObject:ar_object_nid withData:ar_obj];
            }
            
            [self.delegate gotUpdatedData];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Got error when fetching ar_objects");
    }
    
}
-(void)fetchUpdatedARObjects {
    
    if (tries > MAX_NUMBER_OF_TRIES) {
        tries = 0;
        fetching = NO;
        [self alertWithTitle:@"Unable to reach website :("
                  andMessage:@"Cannot download updated places/events..."];
        return;
    }
    if (!siteIsReachable) {
        tries++;
        [self performSelector:@selector(fetchUpdatedARObjects) withObject:nil afterDelay:1];
        return;
    }
    
    if (fetching) return;
    fetching = YES;
    
    NSLog(@"Fetching Updated Places");
    [DIOSARNode getUpdatedARNodes:[dbController getLastUpdateTimestamp]
                          success:^(AFHTTPRequestOperation *operation, id response) {
                              [self saveAllARObjects:response];
                              [dbController saveCurrentTimestamp];
                          }
     
                          failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
                              NSLog(@"got an error: %@", error.description);
                          }];
}


@end
