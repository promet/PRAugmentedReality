//
//  ViewController.m
//  PRAR-Example
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

#import "ViewController.h"
#import "MyLocation.h"

#define LOC_REFRESH_TIMER   10  //seconds
#define MAP_SPAN            804 // The span of the map view

#define MAP_FRAME_P         CGRectMake(0, 160, 320, 317)
#define MAP_FRAME_L         CGRectMake(160, 0, 317, 320)


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
}


#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [prarSwitchL setOn:NO];
    [prarSwitchP setOn:NO];
    
    dataController = [[DataController alloc] init];
    [dataController setDelegate:self];
    
    [arBL setEnabled:NO];
    [arBP setEnabled:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    locRefreshTimer = [NSTimer scheduledTimerWithTimeInterval: LOC_REFRESH_TIMER
                                                       target: self
                                                     selector: @selector(setMapToUserLocation)
                                                     userInfo: nil
                                                      repeats: YES];
    
    [self performSelector:@selector(setMapToUserLocation) withObject:nil afterDelay:1];
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        [_mapView setFrame:MAP_FRAME_L];
        [landscapeControls setHidden:NO];
    } else {
        [_mapView setFrame:MAP_FRAME_P];
        [portraitControls setHidden:NO];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [locRefreshTimer invalidate];
}


#pragma mark - View Segue delegates

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAR"]) {
        ARView *arview = [segue destinationViewController];
        
        [arview setCurrentLoc:_mapView.userLocation.location];
        [arview setArData:arData];
        [arview setDelegate:self];
    }
}
- (void)arViewControllerDidFinish:(ARView *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PRAR system

- (IBAction)startPRAR:(id)sender {
    if (prarSwitchL.on || prarSwitchP.on) {
        [loadingI startAnimating];
        
        if (_mapView.userLocation.location.horizontalAccuracy > 100) {
            [statusLP setText:@"Waiting for accurate location"];
            [statusLL setText:@"Waiting for accurate location"];
            [self performSelector:@selector(startPRAR:) withObject:sender afterDelay:1];
            return;
        }
        
        [statusLP setText:@"Building data"];
        [statusLL setText:@"Building data"];
        [dataController getNearARObjects:_mapView.userLocation.location.coordinate];
    }
}

- (void)gotNearData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];
    [statusLP setText:@"Got Near Data"];
    [statusLL setText:@"Got Near Data"];
    
    [loadingI stopAnimating];
    [arBP setEnabled:YES];
    [arBL setEnabled:YES];
    
    [self plotAllPlaces];
}
- (void)gotAllData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];
    [statusLP setText:@"Got All Data"];
    [statusLL setText:@"Got All Data"];
    
    [loadingI stopAnimating];
    [arBP setEnabled:YES];
    [arBL setEnabled:YES];
    
    [self plotAllPlaces];
}

- (void)gotUpdatedData {
    NSLog(@"Got updated");
}


#pragma mark - Map View Delegate

-(void)setMapToUserLocation {
    
    if (_mapView.userLocation.location.horizontalAccuracy > 100) return;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(_mapView.userLocation.location.coordinate.latitude,
                                                                                                  _mapView.userLocation.location.coordinate.longitude),
                                                                       MAP_SPAN,
                                                                       MAP_SPAN);
    [_mapView setRegion:[_mapView regionThatFits:viewRegion] animated:NO];
    [UIView commitAnimations];
}

-(void)plotAllPlaces {
    for (NSDictionary *place in arData) {
        [self plotPlace:place andId:[place[@"nid"] integerValue]];
    }
}
-(void)plotPlace:(NSDictionary*)somePlace andId:(NSInteger)nid {
    NSString *arObjectName = somePlace[@"title"];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [somePlace[@"lat"] doubleValue];
    coordinates.longitude = [somePlace[@"lon"] doubleValue];
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


#pragma mark - Orientation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation != UIInterfaceOrientationPortrait) {
        [portraitControls setHidden:YES];
        [landscapeControls setHidden:NO];
        [_mapView setFrame:MAP_FRAME_L];
        
        [arBL setEnabled:arBP.enabled];
        [statusLL setText:statusLP.text];
        [prarSwitchL setOn:prarSwitchP.on];
    } else {
        [portraitControls setHidden:NO];
        [landscapeControls setHidden:YES];
        [_mapView setFrame:MAP_FRAME_P];
        
        [arBP setEnabled:arBL.enabled];
        [statusLP setText:statusLL.text];
        [prarSwitchP setOn:prarSwitchL.on];
    }
}


@end
