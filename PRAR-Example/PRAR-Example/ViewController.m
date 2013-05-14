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

@synthesize arController;



#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [prarSwitch setOn:NO];
}

- (void)dealloc {
    [super dealloc];
    
    [prarSwitch release];
    if (arController) [arController release];
}


#pragma mark - View delegates

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (!prarSwitch.on) [self startPRAR:nil];
    
    if ([[segue identifier] isEqualToString:@"showList"]) {
        ListView *listview = [segue destinationViewController];
        [arController setDelegate:listview];
        [listview setArController:arController];
        [listview setDelegate:self];
    }
    
    else if ([[segue identifier] isEqualToString:@"showAR"]) {
        ARView *arview = [segue destinationViewController];
        [arController setDelegate:arview];
        [arview setArController:arController];
        [arview setDelegate:self];
    }
    
    else if ([[segue identifier] isEqualToString:@"showMap"]) {
        MapView *mapview = [segue destinationViewController];
        [arController setDelegate:mapview];
        [mapview setArController:arController];
        [mapview setDelegate:self];
    }
}

- (void)listViewControllerDidFinish:(ListView *)controller {
    [arController setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)arViewControllerDidFinish:(ARView *)controller {
    [arController setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)mapViewControllerDidFinish:(MapView *)controller {
    [arController setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PRAR system

-(IBAction)startPRAR:(id)sender {
    
    if (prarSwitch.on) {
        [prarSwitch setUserInteractionEnabled:NO]; // Safer - Must not risk to restart the arController while its being setup
         arController = [[ARController alloc] initWithScreenSize:self.view.frame.size];
    }
}

@end
