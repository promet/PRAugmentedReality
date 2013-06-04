//
//  ViewController.m
//  PRAR-Example
//
//  Created by Geoffroy Lesage on 5/10/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import "ViewController.h"


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
	// Do any additional setup after loading the view, typically from a nib.
    
    [prarSwitch setOn:NO];
    
    dataController = [[DataController alloc] init];
    [dataController setDelegate:self];
    
    [self setupLocationManager];
}
- (void)dealloc {
    [super dealloc];
    
    [prarSwitch release];
    
    if (dataController) [dataController release];
    if (arData) [arData release];
}


#pragma mark - View delegates

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (!prarSwitch.on) [self startPRAR:nil];
    
    if ([[segue identifier] isEqualToString:@"showList"]) {
        ListView *listview = [segue destinationViewController];
        [listview setDelegate:self];
    }
    
    else if ([[segue identifier] isEqualToString:@"showAR"]) {
        ARView *arview = [segue destinationViewController];
        
        [arview setCurrentLoc:locationManager.location.coordinate];
        [arview setArData:arData];
        
        [arview setDelegate:self];
    }
    
    else if ([[segue identifier] isEqualToString:@"showMap"]) {
        MapView *mapview = [segue destinationViewController];
        [mapview setDelegate:self];
    }
}

- (void)listViewControllerDidFinish:(ListView *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)arViewControllerDidFinish:(ARView *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)mapViewControllerDidFinish:(MapView *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Location

-(void)setupLocationManager {
    locationManager = [[CLLocationManager alloc]init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
}


#pragma mark - PRAR system

- (IBAction)startPRAR:(id)sender {
    if (prarSwitch.on) {
        [loadingI startAnimating];
        
        if (locationManager.location.horizontalAccuracy > MIN_LOCATION_ACCURACY) {
            [statusL setText:@"Waiting for accurate location"];
            [self performSelector:@selector(startPRAR:) withObject:sender afterDelay:1];
            return;
        }
        
        [statusL setText:@"Building data"];
        [dataController getNearARObjects:locationManager.location.coordinate];
    }
}

- (void)gotNearData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];
    [statusL setText:@"Got Near Data"];
    [loadingI stopAnimating];
}
- (void)gotAllData:(NSArray*)arObjects {
    arData = [[NSArray alloc] initWithArray:arObjects];    
    [statusL setText:@"Got All Data"];
    [loadingI stopAnimating];
}

- (void)gotUpdatedData {
    
}

@end
