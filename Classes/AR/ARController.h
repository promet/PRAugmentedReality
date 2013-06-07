//
//  ARController.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 5/28/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "LocationWork.h"


@class ARController;

@protocol ARControllerDelegate
@optional
- (void)arControllerUpdateFrame:(CGRect)arViewFrame;
- (void)arControllerDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer;
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
    
    int locTries;
    int dataTries;
}

@property (assign, nonatomic) id <ARControllerDelegate> delegate;
@property (retain, nonatomic) LocationWork *locWork;

-(id)initWithScreenSize:(CGSize)screenSize;
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate;

-(void)startARWithData:(NSArray*)arData andCurrentLoc:(CLLocationCoordinate2D)currentLocation;
-(void)startARWithData:(NSArray*)arData;
-(void)stopAR;

@end
