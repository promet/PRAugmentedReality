//
//  DataController.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "DataController.h"

#import "DIOSARNode.h"

@implementation DataController


#pragma mark - Main methods

-(id)init {
    self = [super init];
    if (self) {
        
        [self startReachability];
        dbController = [[DBController alloc] init];
        [self fetchUpdatedARObjects];
        
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
    [alert release];
}


#pragma mark - Reachability

-(NSString*)stripHTTPfrom:(NSString*)inputString {
    if ([inputString characterAtIndex:inputString.length-1] == '/') {
        inputString = [inputString stringByPaddingToLength:inputString.length-1 withString:@"" startingAtIndex:0];
    }
    return [inputString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
}
-(void)startReachability {
    SCNetworkReachability *reachability = [[SCNetworkReachability alloc] initWithHostName:[self stripHTTPfrom:kDiosBaseUrl]];
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
-(void)passAllARObjectsToDelegateOnMainThread:(NSDictionary*)arObjects {
    [self.delegate gotAllData:arObjects];
}

-(void)getNearARObjects_IN_BACKGROUND:(CLLocation*)location {
    NSDictionary *arObjects = [dbController getARObjectsNear:location];
    if (!arObjects || arObjects == nil) NSLog(@"uh oh");
}
-(void)getNearARObjects:(CLLocationCoordinate2D)coordinates {
    [self performSelectorInBackground:@selector(getNearARObjects_IN_BACKGROUND:)
                           withObject:[[CLLocation alloc] initWithLatitude:coordinates.latitude
                                                                 longitude:coordinates.longitude]];
}

-(void)getAllARObjects_IN_BACKGROUND:(CLLocation*)location {
    NSDictionary *arObjects = [dbController getAllARObjectsAndSetupWithLoc:location];
    if (!arObjects || arObjects == nil) NSLog(@"uh oh");
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
            for (NSString *ar_object_nid in [newARObjects allKeys]) {
                [dbController saveARObject:ar_object_nid
                                  withData:[newARObjects objectForKey:ar_object_nid]];
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
        [self alertWithTitle:@"Unable to reach website :("
                  andMessage:@"Cannot download updated places/events..."];
        return;
    }
    if (!siteIsReachable) {
        tries++;
        [self performSelector:@selector(fetchUpdatedARObjects) withObject:nil afterDelay:1];
        return;
    }
    
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
