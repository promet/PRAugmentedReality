//
//  PRARManager.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "ARRadar.h"
#import "ARController.h"
#import "ARSettings.h"

/**
 * Those protocols are used by the AR View
 * arControllerUpdateFrame  - Updates the position of the AR Views Containers
 * arControllerDidSetupAR   - Receives the AR data once it is set up or updated
 * gotProblem               - Generic error protocol
 */
@class PRARManager;

@protocol PRARManagerDelegate
@optional
- (void)prarUpdateFrame:(CGRect)arViewFrame;

- (void)prarDidSetupAR:(UIView *)arView
               withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer;

- (void)prarDidSetupAR:(UIView *)arView
               withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer
                  andRadarView:(UIView*)radar;

- (void)prarGotProblem:(NSString*)problemTitle withDetails:(NSString*)problemDetails;

@end

@interface PRARManager : NSObject
{
    
    ARController *arController;
    
    // -- Camera -- //
    AVCaptureSession *cameraSession;
    AVCaptureVideoPreviewLayer *cameraLayer;
    
    // -- Radar -- //
    ARRadar *radar;
    BOOL radarOption;
    
    // -- Other -- //
    CGSize frameSize;
    UIView *arOverlaysContainerView;
    NSTimer *refreshTimer;
}

@property (weak, nonatomic) id <PRARManagerDelegate> delegate;

+ (id)sharedManager;
+ (id)sharedManagerWithSize:(CGSize)size andDelegate:(id)theDelegate;
+ (id)sharedManagerWithRadarAndSize:(CGSize)size andDelegate:(id)theDelegate;

-(void)startARWithData:(NSArray*)arData forLocation:(CLLocationCoordinate2D)location;
-(void)stopAR;

@end
