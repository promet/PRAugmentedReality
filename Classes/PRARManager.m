//
//  PRARManager.m
//  PrometAR
//
// Created by Geoffroy Lesage on 10/07/13.
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

#import "PRARManager.h"

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransform3D.h>

#import "ARObject.h"
#import "LocationMath.h"

@implementation PRARManager

#pragma mark - Life cycle

- (id)initWithSize:(CGSize)size delegate:(id)delegate showRadar:(BOOL)showRadar
{
    self = [super init];
    if (self) {
        frameSize = size;
        radarOption = showRadar;
        _delegate = delegate;
        
        [self initAndAllocContainers];
        [self startCamera];
    }
    return self;
}

- (void)dealloc
{
    [cameraSession stopRunning];
    [refreshTimer invalidate];
}

- (void)initAndAllocContainers
{
    arOverlaysContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                       OVERLAY_VIEW_WIDTH,
                                                                       frameSize.height)];
    [arOverlaysContainerView setTag:AR_VIEW_TAG];
    
    self.arController = [[ARController alloc] init];
}

- (void)startCamera
{
    cameraSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([cameraSession canAddInput:videoIn]) {
                [cameraSession addInput:videoIn];
            } else {
                NSLog(@"Couldn't add video input");
            }
		} else {
            NSLog(@"Couldn't create video input"); }
	} else {
        NSLog(@"Couldn't create video capture device");
    }
    
    cameraLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraSession];// autorelease];
    [cameraLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CGRect layerRect = CGRectMake(0, 0,
                                  frameSize.width,
                                  frameSize.height);
	[cameraLayer setBounds:layerRect];
	[cameraLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
}

#pragma mark - AR Setup

- (void)setupAROverlaysWithData:(NSDictionary*)arObjectsDict
{
    [[arOverlaysContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSNumber *ar_id in arObjectsDict.allKeys) {
        [arOverlaysContainerView addSubview:[arObjectsDict[ar_id] view]];
    }
}

- (void)setupRadar
{
    NSArray *spots = [self.arController createRadarSpots];
    
    radar = [[ARRadar alloc] initWithFrame:CGRectMake((frameSize.width/2)-50, frameSize.height-100, 100, 100)
                                 withSpots:spots];
}


#pragma mark - Refresh Of Overlay Positions

-(void)refreshPositionOfOverlay
{
    CGRect newPos = [self.arController.locationMath getCurrentFramePosition];
    [radar moveDots:[self.arController.locationMath getCurrentHeading]];
    
    [self.delegate prarUpdateFrame:CGRectMake(newPos.origin.x,
                                              newPos.origin.y,
                                              OVERLAY_VIEW_WIDTH,
                                              frameSize.height)];
}

#pragma mark - AR controls

- (void)stopAR
{
    [refreshTimer invalidate];
}

- (void)startARWithData:(NSArray*)arData forLocation:(CLLocationCoordinate2D)location
{
    if (arData.count < 1) {
        [self.delegate prarGotProblem:@"No AR Data" withDetails:nil];
        return;
    }
    
    NSLog(@"Starting AR with %lu places", (unsigned long)arData.count);
    
    [self.arController.locationMath startTrackingWithLocation:location
                                                   andSize:frameSize];
    NSDictionary *arObjectsDict = [self.arController buildAROverlaysForData:arData
                                                           andLocation:location];
    [self setupAROverlaysWithData:arObjectsDict];
    if (radarOption) [self setupRadar];
    [cameraSession startRunning];
    
    if (radarOption) {
        [self.delegate prarDidSetupAR:arOverlaysContainerView
                      withCameraLayer:cameraLayer
                         andRadarView:radar];
    }
    else {
        [self.delegate prarDidSetupAR:arOverlaysContainerView
                      withCameraLayer:cameraLayer];
    }
    
    refreshTimer = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(refreshPositionOfOverlay)];
    [refreshTimer addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
}

@end
