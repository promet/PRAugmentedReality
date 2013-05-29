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

@synthesize arController;


#pragma mark - AR Controller Delegate

- (void)arControllerDidSetupDataAndAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer {
    NSLog(@"Finished displaying ARObjects");
    
    [self.view.layer addSublayer:cameraLayer];
    [self.view addSubview:arView];
    
    [loadingI stopAnimating];
}
- (void)arControllerDidSetupData:(NSDictionary *)arObjects {
    [arController startAR];
}
- (void)arControllerUpdatePosition:(CGRect)arViewFrame {
    [[self.view viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
}

- (void)arControllerGotUpdatedData {
    [arController startAR];
}

- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details {

    [loadingI stopAnimating];
     
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:problemOrigin
                                                    message:details
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - View Management

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [loadingI startAnimating];
    [arController startAR];
}
-(void)viewWillDisappear:(BOOL)animated {
    [arController stopAR];
    [super viewWillDisappear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate arViewControllerDidFinish:self];
}

@end
