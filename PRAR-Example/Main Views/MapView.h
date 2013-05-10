//
//  MapView.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyLocation.h"
#import "ARController.h"

@class MapView;

@protocol MapViewDelegate
- (void)mapViewControllerDidFinish:(MapView *)controller;
@end

@interface MapView : UIViewController <ARControllerDelegate, MKMapViewDelegate> {
    ARController *arController;
    
    NSMutableDictionary *arObjectsDictionary;
    
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    int attempts;
}

@property (assign, nonatomic) id <MapViewDelegate> delegate;
@property (nonatomic, retain) ARController *arController;

@property (nonatomic, retain) IBOutlet MKMapView *_mapView;

- (IBAction)done:(id)sender;

@end