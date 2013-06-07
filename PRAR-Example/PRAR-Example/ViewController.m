//
//  ViewController.m
//  PRAR-Example
//
//  Created by Geoffroy Lesage on 5/10/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import "ViewController.h"
#import "MyLocation.h"

#define LOC_REFRESH_TIMER   10 //seconds


@interface ViewController ()

@end


@implementation ViewController


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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [prarSwitch setOn:NO];
    
    dataController = [[DataController alloc] init];
    [dataController setDelegate:self];
    
    [arB setEnabled:NO];
}
- (void)dealloc {
    [super dealloc];
    
    [prarSwitch release];
    
    if (dataController) [dataController release];
    if (arData) [arData release];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    locRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: LOC_REFRESH_TIMER
                                                       target: self
                                                     selector: @selector(setMapToUserLocation)
                                                     userInfo: nil
                                                      repeats: YES];
    
    [self performSelector:@selector(setMapToUserLocation) withObject:nil afterDelay:LOC_REFRESH_TIMER/2];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [locRefreshTimer invalidate];
}


#pragma mark - View Segue delegates

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (!prarSwitch.on) [self startPRAR:nil];
    
    if ([[segue identifier] isEqualToString:@"showAR"]) {
        ARView *arview = [segue destinationViewController];
        
        [arview setArData:arData];
        [arview setDelegate:self];
    }
}
- (void)arViewControllerDidFinish:(ARView *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PRAR system

- (IBAction)startPRAR:(id)sender {
    if (prarSwitch.on) {
        [loadingI startAnimating];
        
        if (_mapView.userLocation.location.horizontalAccuracy > MIN_LOCATION_ACCURACY) {
            [statusL setText:@"Waiting for accurate location"];
            [self performSelector:@selector(startPRAR:) withObject:sender afterDelay:1];
            return;
        }
        
        [statusL setText:@"Building data"];
        [dataController getNearARObjects:_mapView.userLocation.location.coordinate];
    }
}

- (void)gotNearData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];
    [statusL setText:@"Got Near Data"];
    
    [loadingI stopAnimating];
    [arB setEnabled:YES];
    
    [self plotAllPlaces];
}
- (void)gotAllData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];
    [statusL setText:@"Got All Data"];
    
    [loadingI stopAnimating];
    [arB setEnabled:YES];
    
    [self plotAllPlaces];
}

- (void)gotUpdatedData {
    
}


#pragma mark - Map View Delegate

-(void)setMapToUserLocation {
    
    if (_mapView.userLocation.location.horizontalAccuracy > MIN_LOCATION_ACCURACY) return;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(_mapView.userLocation.location.coordinate.latitude,
                                                                                                  _mapView.userLocation.location.coordinate.longitude),
                                                                       METERS_PER_MILE_OVER_2,
                                                                       METERS_PER_MILE_OVER_2);
    [_mapView setRegion:[_mapView regionThatFits:viewRegion] animated:YES];
    [UIView commitAnimations];
}

-(void)plotAllPlaces {
    for (NSDictionary *place in arData) {
        [self plotPlace:place andId:[[place objectForKey:@"nid"] integerValue]];
    }
}
-(void)plotPlace:(NSDictionary*)somePlace andId:(NSInteger)nid {
    NSString *arObjectName = [somePlace objectForKey:@"title"];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[somePlace objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[somePlace objectForKey:@"lon"] doubleValue];
    MyLocation *annotation = [[MyLocation alloc] initWithName:arObjectName coordinate:coordinates andId:nid] ;
    [_mapView addAnnotation:annotation];
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
        
        return annotationView;
    }
    return nil;
}

@end
