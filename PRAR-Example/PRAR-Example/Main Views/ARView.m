//
//  ARView.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "ARView.h"


@interface ARView ()

@end


@implementation ARView

@synthesize arData;


- (void)alert:(NSString*)title withDetails:(NSString*)details {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:details
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - AR Controller Delegate

- (void)arControllerDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer {
    NSLog(@"Finished displaying ARObjects");
    
    [self.view.layer addSublayer:cameraLayer];
    [self.view addSubview:arView];
    
    [self.view bringSubviewToFront:[self.view viewWithTag:1992]];
    
    [loadingI stopAnimating];
}
- (void)arControllerUpdateFrame:(CGRect)arViewFrame {
    [[self.view viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
}
- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details {

    [loadingI stopAnimating];
    
    [self alert:problemOrigin withDetails:details];
}


#pragma mark - View Management

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (arData.count > 0) {
        [loadingI startAnimating];
        [arController startARWithData:arData];
        return;
    }
    
    [self alert:@"No data" withDetails:nil];
}
-(void)viewWillDisappear:(BOOL)animated {
    [arController stopAR];
    [super viewWillDisappear:animated];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    arController = [[ARController alloc] initWithScreenSize:self.view.frame.size
                                                andDelegate:self];
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    //[arController release];
    
    [self.delegate arViewControllerDidFinish:self];
}

@end
