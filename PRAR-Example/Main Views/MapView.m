//
//  MapView.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "MapView.h"

#define MAP_OVERLAY_X           20
#define MAP_OVERLAY_Y           184

#define MAX_NUMBER_OF_TRIES     5


@interface MapView ()

@end


@implementation MapView

@synthesize _mapView;
@synthesize arController;


- (void)alert:(NSString*)title withDetails:(NSString*)details {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:details
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - View Management

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
    [arController performSelectorInBackground:@selector(setupNeardata) withObject:nil];
    [self setMapToUserLocation];
     */
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [loadingIndicator stopAnimating];
}

- (void)dealloc {
    [super dealloc];
    
    [arController setDelegate:nil];
    [arController release];
    
    [arObjectsDictionary release];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)done:(id)sender {
    [self.delegate mapViewControllerDidFinish:self];
}


#pragma mark - AR Controller Delegate

- (void)arControllerDidSetupData:(NSDictionary*)arObjects {    
    if (arObjectsDictionary) [arObjectsDictionary release];
    [_mapView removeAnnotations:_mapView.annotations];
    
    arObjectsDictionary = [[NSMutableDictionary alloc] initWithDictionary:arObjects];
    for (ARObject *arObject in [arObjectsDictionary allValues]) {
        [self plotARObject:arObject andId:[[[arObject getARObjectData] objectForKey:@"id"] integerValue]];
    }
    
    [loadingIndicator stopAnimating];
}
- (void)arControllerGotUpdatedData {
    [arController performSelectorInBackground:@selector(setupNeardata) withObject:nil];
}

- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details {
    [self alert:problemOrigin withDetails:details];
}


#pragma mark - Map View Delegate

-(void)setMapToUserLocation {
    if (attempts == MAX_NUMBER_OF_TRIES) {
        [self gotProblemIn:@"Location for map :(" withDetails:@"Can't seem to pinpoint your location..."];
        return;
    }
    if (!arController.locWork.gotPreciseEnoughLocation) {
        attempts++;
        [self performSelector:@selector(setMapToUserLocation)
                   withObject:nil
                   afterDelay:1];
    }
    attempts = 0;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(arController.locWork.currentLat,
                                                                                                  arController.locWork.currentLon),
                                                                       METERS_PER_MILE_OVER_2,
                                                                       METERS_PER_MILE_OVER_2);
    [_mapView setRegion:[_mapView regionThatFits:viewRegion] animated:YES];
    [UIView commitAnimations];
}
-(void)plotARObject:(ARObject*)someARObject andId:(NSInteger)nid {
    NSString *arObjectName = [[someARObject getARObjectData] objectForKey:@"title"];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[[someARObject getARObjectData] objectForKey:@"latitude"] doubleValue];
    coordinates.longitude = [[[someARObject getARObjectData] objectForKey:@"longitude"] doubleValue];
    MyLocation *annotation = [[MyLocation alloc] initWithName:arObjectName coordinate:coordinates andId:nid] ;
    [_mapView addAnnotation:annotation];
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {    
    for (ARObject *arObject in [arObjectsDictionary allValues]) {
        [[self.view viewWithTag:[[[arObject getARObjectData] objectForKey:@"id"] integerValue]] removeFromSuperview];
    }
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    //Move the map to center the view
    CLLocationCoordinate2D zoomLocation = [(MyLocation*)view.annotation coordinate];
    if (self.view.frame.size.height == 548) {   // You're on an iPhone 5
        zoomLocation.latitude -= 0.0015;
        zoomLocation.longitude -= 0.0035;
    } else {                                    // You're on an older iPhone
        zoomLocation.latitude -= 0.0005;
        zoomLocation.longitude -= 0.005;
    }
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE_OVER_2, METERS_PER_MILE_OVER_2);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
    
    [UIView commitAnimations];
    
    //Create and display the view
    ARObject *arObject = [arObjectsDictionary objectForKey:[NSNumber numberWithInt:view.tag/10]];;
    [arObject.view setHidden:NO];
    [arObject.view setFrame:CGRectMake(MAP_OVERLAY_X-self.view.frame.size.width,
                                       MAP_OVERLAY_Y,
                                       arObject.view.frame.size.width,
                                       arObject.view.frame.size.height)];
    [self.view addSubview:arObject.view];
    
    [UIView beginAnimations:@"animateOverlay" context:nil];
    [UIView setAnimationDuration:0.5];
    
    [arObject.view setFrame:CGRectMake(MAP_OVERLAY_X,
                                       MAP_OVERLAY_Y,
                                       arObject.view.frame.size.width,
                                       arObject.view.frame.size.height)];
    [UIView commitAnimations];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [annotationView setTag:[(MyLocation*)annotation nid]*10];
        
        return annotationView;
    }
    return nil;
}


@end
