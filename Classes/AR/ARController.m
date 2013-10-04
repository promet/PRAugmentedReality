//
//  ARController.m
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

#import "ARController.h"
#import "ARObject.h"

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATransform3D.h>

@interface ARController ()

@end


@implementation ARController

@synthesize locWork;


// -- Shape warper -- //
#define CATransform3DPerspective(t, x, y) (CATransform3DConcat(t, CATransform3DMake(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)))
#define CATransform3DMakePerspective(x, y) (CATransform3DPerspective(CATransform3DIdentity, x, y))

CG_INLINE CATransform3D
CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
				  CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
				  CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
				  CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44)
{
	CATransform3D t;
	t.m11 = m11; t.m12 = m12; t.m13 = m13; t.m14 = m14;
	t.m21 = m21; t.m22 = m22; t.m23 = m23; t.m24 = m24;
	t.m31 = m31; t.m32 = m32; t.m33 = m33; t.m34 = m34;
	t.m41 = m41; t.m42 = m42; t.m43 = m43; t.m44 = m44;
	return t;
}


-(void)refreshPositionOfOverlay {
    CGRect newPos = [locWork getCurrentFramePosition];
    [radar moveDots:[locWork getCurrentHeading]];
    [[self delegate] arControllerUpdateFrame:CGRectMake(newPos.origin.x,
                                                        newPos.origin.y,
                                                        OVERLAY_VIEW_WIDTH,
                                                        deviceScreenResolution.height)];
}


#pragma mark - Data Delegate

-(void)startARWithData:(NSArray*)arData andCurrentLoc:(CLLocationCoordinate2D)currentLocation {
    if (locTries == MAX_NUMBER_OF_TRIES) {
        [self.delegate gotProblemIn:@"Location :(" withDetails:@"Can't seem to pinpoint your location..."];
        return;
    }
    else if (!locWork.gotPreciseEnoughLocation) {
        locTries++;
        [self performSelector:@selector(startARWithData:)
                   withObject:arData
                   afterDelay:1];
        return;
    }
    
    locTries = 0;
    [self buildAROverlays:arData andCurrentLoc:currentLocation];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE
                                                    target:self
                                                  selector:@selector(refreshPositionOfOverlay)
                                                  userInfo:nil
                                                   repeats:YES];
}
-(void)startARWithData:(NSArray*)arData {
    [self startARWithData:arData andCurrentLoc:CLLocationCoordinate2DMake(locWork.currentLat, locWork.currentLon)];
}


#pragma mark - AR builders

-(void)buildAROverlays:(NSArray*)arData andCurrentLoc:(CLLocationCoordinate2D)currentLocation {
    
    int x_pos = 0;
    ARObject *arObject;
    NSMutableArray *spots = [NSMutableArray array];
    
    for (NSDictionary *arObjectData in arData) {
        NSNumber *ar_id = @([arObjectData[@"nid"] intValue]);
        arObject = [[ARObject alloc] initWithId:ar_id.intValue
                                           title:arObjectData[@"title"]
                                     coordinates:CLLocationCoordinate2DMake([arObjectData[@"lat"] doubleValue],
                                                                            [arObjectData[@"lon"] doubleValue])
                              andCurrentLocation:currentLocation];
        
        x_pos = [locWork getARObjectXPosition:arObject]-arObject.view.frame.size.width;
        
        if (RADAR_ON) {
            NSDictionary *spot = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:(int)(x_pos/HORIZ_SENS)],         @"angle",
                                  [NSNumber numberWithFloat:arObject.distance.floatValue],  @"distance",
                                  nil];
            [spots addObject:spot];
        }
        
        geoobjectOverlays[ar_id] = arObject;
        geoobjectPositions[ar_id] = @(x_pos);
        geoobjectVerts[ar_id] = @1;
    }
    
    [cameraSession startRunning];
    
    [self setupDataForAR];
    
    if (radarOption) {
        radar = [[ARRadar alloc] initWithFrame:CGRectMake((deviceScreenResolution.width/2)-50, deviceScreenResolution.height-100, 100, 100)
                                     withSpots:[NSArray arrayWithArray:spots]];
        
        [self.delegate arControllerDidSetupAR:arOverlaysContainerView
                              withCameraLayer:cameraLayer
                                 andRadarView:radar];
    }
    else [self.delegate arControllerDidSetupAR:arOverlaysContainerView
                               withCameraLayer:cameraLayer];
}

-(void)setupDataForAR {
    
    [[arOverlaysContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setVerticalPosWithDistance];
    [self checkForVerticalPosClashes];
    [self checkAllVerticalPos];
    
    [self setFramesForOverlays];
}

// Warps the view into a parrallelogram shape in order to give it a 3D perspective
-(void)warpView:(UIView*)arView atVerticalPosition:(int)verticalPos {
    
    arView.layer.sublayerTransform = CATransform3DMakePerspective(0, verticalPos*-0.0004);
    
    float shrinkLevel = powf(0.9, verticalPos-1);
    arView.transform = CGAffineTransformMakeScale(shrinkLevel, shrinkLevel);
    
}
-(int)setYPosForView:(UIView*)arView atVerticalPos:(int)verticalPos {
    
    int pos = Y_CENTER-(int)(arView.frame.size.height*verticalPos);
    pos -= (powf(verticalPos, 2)*4);
    
    return pos-(arView.frame.size.height/2);
}

-(void)setVerticalPosWithDistance {
    
    ARObject *arObject;
    int distance;
    
    for (NSString *key in [geoobjectOverlays allKeys]) {
        
        arObject = geoobjectOverlays[key];
        distance = (int)(arObject.distance.doubleValue);
        
        if (distance < 20) {
            [geoobjectVerts setValue:@0 forKey:key];
        }
        else if (distance < 50) {
            [geoobjectVerts setValue:@1 forKey:key];
        }
        else if (distance < 100) {
            [geoobjectVerts setValue:@2 forKey:key];
        }
        else if (distance < 200) {
            [geoobjectVerts setValue:@3 forKey:key];
        }
        else if (distance < 300) {
            [geoobjectVerts setValue:@4 forKey:key];
        }
        else {
            [geoobjectVerts setValue:@5 forKey:key];
        }
    }
}
-(void)checkForVerticalPosClashes {
    
    int distance, sub_distance, diff, x_pos, vertPosition, sub_vertPosition;
    int overlay_width = ((ARObject*)[geoobjectOverlays allValues][0]).view.frame.size.width;
    BOOL gotConflict = YES;
    
    while (gotConflict) {
        gotConflict = NO;
        
        for (NSString *key in [geoobjectOverlays allKeys]) {
            
            vertPosition = [geoobjectVerts[key] intValue];
            distance = (int)([(ARObject*)geoobjectOverlays[key] distance].doubleValue);
            x_pos = [geoobjectPositions[key] intValue];
            
            for (NSString *sub_key in [geoobjectOverlays allKeys]) {
                if ([sub_key intValue] == [key intValue]) continue;
                
                sub_vertPosition = [geoobjectVerts[sub_key] intValue];
                if (vertPosition != sub_vertPosition) continue;
                
                diff = x_pos-[geoobjectPositions[sub_key] intValue];
                sub_distance = [(ARObject*)geoobjectOverlays[sub_key] distance].intValue;
                
                if (diff < 0) diff = -diff;
                if (diff > overlay_width) continue;
                
                gotConflict = YES;
                
                if (diff < overlay_width && sub_distance<distance) {
                    vertPosition++;
                    
                } else if (diff < overlay_width) {
                    [geoobjectVerts setValue:@(sub_vertPosition+1) forKey:sub_key];
                }
            }
            
            [geoobjectVerts setValue:@(vertPosition) forKey:key];
        }
    }
}
-(void)checkAllVerticalPos {
    
    NSNumber *vert;
    while (![[geoobjectVerts allValues] containsObject:@0]) {
        for (NSNumber *key in [geoobjectVerts allKeys]) {
            vert = geoobjectVerts[key];
            geoobjectVerts[key] = @(vert.intValue-1);
        }
    }
}
-(void)setFramesForOverlays {
    
    int distance, x_pos, y_pos, vertPosition;
    
    for (ARObject *arObject in [geoobjectOverlays allValues]) {
        NSNumber *arObjectId = (arObject.getARObjectData)[@"id"];
        
        x_pos = [geoobjectPositions[arObjectId] intValue];
        vertPosition = [geoobjectVerts[arObjectId] intValue];
        y_pos = [self setYPosForView:arObject.view atVerticalPos:vertPosition];
        distance = (int)(arObject.distance.doubleValue);
        
        // Subtract the half the width to the x_pos so it points to the right place with it's right tip
        [arObject.view setFrame:CGRectMake(x_pos, y_pos,
                                           arObject.view.frame.size.width,
                                           arObject.view.frame.size.height)];
        
        [self warpView:arObject.view atVerticalPosition:vertPosition];
        
        [arOverlaysContainerView addSubview:arObject.view];
    }
}

-(void)stopAR {
    [refreshTimer invalidate];
}


#pragma mark - Main Initialization

-(void)initAndAllocContainers {
    geoobjectOverlays = [[NSMutableDictionary alloc] init];
    geoobjectPositions = [[NSMutableDictionary alloc] init];
    geoobjectVerts = [[NSMutableDictionary alloc] init];
    
    arOverlaysContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                       OVERLAY_VIEW_WIDTH,
                                                                       deviceScreenResolution.height)];
    [arOverlaysContainerView setTag:AR_VIEW_TAG];
}

-(void)startPosMonitoring {
    locWork = [[LocationWork alloc] init];
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
    
    CGRect layerRect = CGRectMake(0, 0,
                                  deviceScreenResolution.width,
                                  deviceScreenResolution.height);
	[cameraLayer setBounds:layerRect];
	[cameraLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
}

-(id)initWithScreenSize:(CGSize)screenSize withRadar:(BOOL)withRadar {
    self = [super init];
    if (self) {
        
        deviceScreenResolution = screenSize;
        
        locTries = 0;
        dataTries = 0;
        
        radarOption = withRadar;
        
        [self initAndAllocContainers];
        [self startPosMonitoring];
        [self startCamera];
    }
    return self;
}
-(id)initWithScreenSize:(CGSize)screenSize andDelegate:(id)delegate withRadar:(BOOL)withRadar {
    self = [self initWithScreenSize:screenSize withRadar:withRadar];
    if (self) {
        [self setDelegate:delegate];
    }
    return self;
}

-(void)dealloc {
    
	[cameraSession stopRunning];
    
    
    [refreshTimer invalidate];
    
    
    
}

@end
