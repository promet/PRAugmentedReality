//
//  ARController.h
//  PrometAR
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "LocationWork.h"
#import "ARRadar.h"

/**
 * Those protocols are used by the AR View
 * arControllerUpdateFrame  - Updates the position of the AR Views Containers
 * arControllerDidSetupAR   - Receives the AR data once it is set up or updated
 * gotProblemIn             - Generic error protocol
 */
@class ARController;

@protocol ARControllerDelegate
@optional
- (void)arControllerUpdateFrame:(CGRect)arViewFrame;

- (void)arControllerDidSetupAR:(UIView *)arView
               withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer;

- (void)arControllerDidSetupAR:(UIView *)arView
               withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer
                  andRadarView:(UIView*)radar;

- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details;
@end


@interface ARController : NSObject {
    
    // -- Main Handler Classes -- //
    LocationWork *locWork;
    
    // -- Main Containers -- //
    NSMutableDictionary *geoobjectOverlays;
    NSMutableDictionary *geoobjectPositions;
    NSMutableDictionary *geoobjectVerts;
    
    // -- Camera -- //
    AVCaptureSession *cameraSession;
    AVCaptureVideoPreviewLayer *cameraLayer;
    
    // -- Other -- //
    CGSize deviceScreenResolution;
    UIView *arOverlaysContainerView;
    NSTimer *refreshTimer;

    ARRadar *radar;
    
    int locTries;
    int dataTries;
}

@property (weak, nonatomic) id <ARControllerDelegate> delegate;
@property (strong, nonatomic) LocationWork *locWork;

-(id)initWithScreenSize:(CGSize)screenSize;
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate;

-(void)startARWithData:(NSArray*)arData andCurrentLoc:(CLLocationCoordinate2D)currentLocation;
-(void)startARWithData:(NSArray*)arData;
-(void)stopAR;

@end
