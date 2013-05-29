//
//  ARController.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 5/28/13.
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
- (void)arControllerDidSetupDataAndAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer;
- (void)arControllerDidSetupData:(NSDictionary*)arObjects;

- (void)arControllerUpdatePosition:(CGRect)arViewFrame;
- (void)arControllerGotUpdatedData;

- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details;
@end


@interface ARController : NSObject <ARObjectsDataDelegate> {
    
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
    
    BOOL gotUpdate;
    int locTries;
    int dataTries;
}

@property (assign, nonatomic) id <ARControllerDelegate> delegate;
@property (retain, nonatomic) DataController *dataController;
@property (retain, nonatomic) LocationWork *locWork;

-(id)initWithScreenSize:(CGSize)screenSize;
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate;

-(void)setupAllData;
-(void)setupNeardata;
-(void)startAR;
-(void)stopAR;

@end
