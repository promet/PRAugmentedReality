//
//  ARController.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/12/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "ARController.h"
#import "ARObject.h"

@interface ARController ()

@end


@implementation ARController

@synthesize dataController;
@synthesize locWork;


-(void)refreshPositionOfOverlay {
    CGRect newPos = [locWork getCurrentFramePosition];
    [[self delegate] arControllerUpdatePosition:CGRectMake(newPos.origin.x,
                                                           newPos.origin.y,
                                                           OVERLAY_VIEW_WIDTH,
                                                           deviceScreenResolution.height-TOOLBAR_HEIGHT)];
}


#pragma mark - Data Delegate

- (void)gotNearARData:(NSArray*)arObjects {
    
    int x_pos;
    for (ARObject *arObject in arObjects) {
        x_pos = [locWork getARObjectXPosition:arObject];
        
        [geoobjectOverlays setObject:arObject
                              forKey:[arObject.getARObjectData objectForKey:@"id"]];
        
        [geoobjectPositions setObject:[NSNumber numberWithInt:x_pos]
                               forKey:[arObject.getARObjectData objectForKey:@"id"]];
        
        [geoobjectVerts setObject:[NSNumber numberWithInt:1]
                           forKey:[arObject.getARObjectData objectForKey:@"id"]];
    }
    
    [[self delegate] arControllerDidFinishWithData:geoobjectOverlays];
    
    [dataController performSelector:@selector(fetchUpdatedARObjects) withObject:nil afterDelay:DELAY_FOR_UPDATE];
    
    [[NSNotificationCenter defaultCenter] addObserver:dataController
                                             selector:@selector(fetchUpdatedARObjects)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)gotUpdatedARNearData:(NSArray*)arObjects {
    int x_pos;
    for (ARObject *arObject in arObjects) {
        x_pos = [locWork getARObjectXPosition:arObject];
        
        [geoobjectOverlays setObject:arObject
                              forKey:[arObject.getARObjectData objectForKey:@"id"]];
        
        [geoobjectPositions setObject:[NSNumber numberWithInt:x_pos]
                               forKey:[arObject.getARObjectData objectForKey:@"id"]];
        
        [geoobjectVerts setObject:[NSNumber numberWithInt:1]
                           forKey:[arObject.getARObjectData objectForKey:@"id"]];
    }
    
    [[self delegate] arControllerDidFinishWithData:geoobjectOverlays];
}
- (void)gotAllARData:(NSDictionary*)arObjects {
    [[self delegate] arControllerDidFinishWithData:arObjects];
}


#pragma mark - Location Delegate

- (void)gotPreciseLocation:(CLLocationCoordinate2D)preciseLocation {
    [dataController getGeoObjectsNear:preciseLocation forUpdate:NO];
}


#pragma mark - Initialisers

-(void)setupDataForAR {
    
    int distance, diff, x_pos;
    int vertPosition = 1;
    
    // Figure out the vertical position of the overlays
    startLoop:
        for (ARObject *arObject in [geoobjectOverlays allValues]) {
            NSNumber *arObjectId = [arObject.getARObjectData objectForKey:@"id"];
            
            x_pos = [[geoobjectPositions objectForKey:arObjectId] intValue];
            distance = [[geoobjectVerts objectForKey:arObjectId] intValue];
            vertPosition = [[geoobjectVerts objectForKey:arObjectId] intValue];
            
            for (NSNumber *sub_key in [geoobjectOverlays allKeys]) {
                if ([sub_key intValue] == [arObjectId intValue]) continue;
                
                diff = x_pos-[[geoobjectPositions objectForKey:sub_key] intValue];
                
                if (diff < 0) diff = -diff;
                if (diff < arObject.view.frame.size.width && vertPosition == [[geoobjectVerts objectForKey:sub_key] intValue]) {
                    vertPosition++;
                    [geoobjectVerts setValue:[NSNumber numberWithInt:vertPosition]
                                      forKey:arObjectId];
                    goto startLoop;
                }
            }
            
            // Subtract the half the width to the x_pos so it points to the right place with it's right tip
            [arObject.view setFrame:CGRectMake(x_pos-(arObject.view.frame.size.width/2),
                                               (int)(Y_CENTER-((arObject.view.frame.size.height+2)*vertPosition)),
                                               arObject.view.frame.size.width,
                                               arObject.view.frame.size.height)];
            
            [arOverlaysContainerView addSubview:arObject.view];
        }
}
-(void)startAR {
    [cameraSession startRunning];
    [self setupDataForAR];
    
    [[self delegate] arControllerDidFinishForAR:arOverlaysContainerView withCameraLayer:cameraLayer];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE
                                                    target:self
                                                  selector:@selector(refreshPositionOfOverlay)
                                                  userInfo:nil
                                                   repeats:YES];
}
-(void)stopAR {
    [refreshTimer invalidate];
}

-(void)initAndAllocContainers {
    geoobjectOverlays = [[NSMutableDictionary alloc] init];
    geoobjectPositions = [[NSMutableDictionary alloc] init];
    geoobjectVerts = [[NSMutableDictionary alloc] init];
    
    arOverlaysContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       TOOLBAR_HEIGHT,
                                                                       OVERLAY_VIEW_WIDTH,
                                                                       deviceScreenResolution.height-TOOLBAR_HEIGHT)];
    [arOverlaysContainerView setTag:AR_VIEW_TAG];
}
-(void)startDataController {
    dataController = [[DataController alloc] init];
    [dataController setDelegate:self];
}
-(void)startPosMonitoring {
    locWork = [[LocationWork alloc] init];
    [locWork setDelegate:self];
    [locWork startAR:deviceScreenResolution];
}
-(void)startCamera {    
    cameraSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([cameraSession canAddInput:videoIn]) [cameraSession addInput:videoIn];
			else    NSLog(@"Couldn't add video input");
		} else      NSLog(@"Couldn't create video input");
	} else          NSLog(@"Couldn't create video capture device");
    
    cameraLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraSession];// autorelease];
    [cameraLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CGRect layerRect = CGRectMake(0,
                                  TOOLBAR_HEIGHT,
                                  deviceScreenResolution.width,
                                  deviceScreenResolution.height-TOOLBAR_HEIGHT);
	[cameraLayer setBounds:layerRect];
	[cameraLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
}

-(id)initWithScreenSize:(CGSize)screenSize {
    self = [super init];
    if (self) {
        
        deviceScreenResolution = screenSize;
        
        [self initAndAllocContainers];
        [self startDataController];
        [self startPosMonitoring];
        [self startCamera];
    }
    return self;
}
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate {
    self = [self initWithScreenSize:screenSize];
    if (self) {
        [self setDelegate:delegate];
    }
    return self;
}
-(void)dealloc {
    [super dealloc];
    
	[cameraSession stopRunning];
    
	[cameraLayer release];
	[cameraSession release];
    
    [refreshTimer invalidate];
    [geoobjectOverlays release];
    [geoobjectPositions release];
    [geoobjectVerts release];
    [locWork release];
}

@end
