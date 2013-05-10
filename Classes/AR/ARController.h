//
//  ARController.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "LocationWork.h"
#import "DataController.h"


@class ARController;

@protocol ARControllerDelegate
@optional
- (void)arControllerDidFinishForAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer;
- (void)arControllerDidFinishWithData:(NSDictionary*)arObjects;
- (void)arControllerUpdatePosition:(CGRect)arViewFrame;
@end


@interface ARController : NSObject <ARObjectsDataDelegate, LocationWorkDelegate> {
    // -- Main Handler Classes -- //
    LocationWork *locWork;
    DataController *dataController;
    
    
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
}

@property (assign, nonatomic) id <ARControllerDelegate> delegate;
@property (retain, nonatomic) DataController *dataController;
@property (retain, nonatomic) LocationWork *locWork;

-(id)initWithScreenSize:(CGSize)screenSize;
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate;

-(void)startAR;
-(void)stopAR;

@end
