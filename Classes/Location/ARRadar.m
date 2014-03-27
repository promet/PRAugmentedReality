//
//  ARRadar.m
//  PRAR-Example
//
//  Created by ANDREW KUCHARSKI on 8/29/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ARRadar.h"

@interface ARRadar ()

@end

@implementation ARRadar


#pragma mark - Drawing Override
/*
 * This is to draw on the places on the Radar
 *
 * It is done for each spot, in the following steps:
 *
 * 1. Get & check the heading angle (position over 360 degrees)
 *
 * 2. Get a ratio of the angle over 90 degrees
 *    (ex:72 is 0.8 of 90 and 27 is 30% of 90)
 *
 * 3. Get a ration of the distance compared to the rest
 *    (how far is it compared to the others, where 1 is the maximum
 *    distance and 0 is the minimum)
 *
 * 4. Depending on which section of the axis it is, do the math
 *    (Could be 0 < x < 90
 *              90 < x < 180
 *              180 < x < 270
 *              270 < x < 360
 *    The math involves adding a number to the minimum x or y value for
 *    that particular quadrant of the axis.
 *    That number is based on the angle ration over 90 degrees (step 2.)
 *
 * 5. Add/subtract the x/y value depending on the distance ratio (step 3.)
 *
 */

// Those are the N-E-S-W points (highs and lows) of the axis of the radar //
#define Nx  49
#define Ny  10
#define Ex  85
#define Ey  48
#define Sx  49
#define Sy  85
#define Wx  10
#define Wy  48


#pragma mark - Creating the radar image

- (void)drawRect:(CGRect)rect
{
    if (theSpots.count < 1) return;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(contextRef, 0.2, 1, 0.2, 0.8);
    
    int max = [[[theSpots allValues] valueForKeyPath:@"@max.intValue"] intValue];
    int min = [[[theSpots allValues] valueForKeyPath:@"@min.intValue"] intValue];
    
    int x = 0;
    int y = 0;
    
    for (NSNumber *angle in theSpots.allKeys) {
        
        // Angle modifier //
        int angleI = angle.intValue;
        float angleModifier = fmod(angleI,90)/90.0;
        
        // Distance modifier //
        float distModifier = 0;
        if ([[theSpots objectForKey:angle] intValue] != min) {
            distModifier = 1-(([[theSpots objectForKey:angle] floatValue]-min)/(max-min));
        }
        
        // Positioning on axis //
        if (angleI < 90) {
            float xWidth = Ex-Nx;
            x = Nx+(xWidth*angleModifier);
            x-=(xWidth*distModifier)*((x-Nx)/xWidth);
            
            float yWidth = Ey-Ny;
            y = Ey-(yWidth*angleModifier);
            y+=(yWidth*distModifier)*((y-Ny)/yWidth);
        }
        else if (angleI < 180) {
            float xWidth = Ex-Sx;
            x = Ex-(xWidth*angleModifier);
            x+=(xWidth*distModifier)*(1-((x-Sx)/xWidth));
            
            float yWidth = Sy-Ey;
            y = Ey+(yWidth*angleModifier);
            y-=(yWidth*distModifier)*((y-Ey)/yWidth);
        }
        
        else if (angleI < 270) {
            float xWidth = Sx-Wx;
            x = Sx-(xWidth*angleModifier);
            x+=(xWidth*distModifier)*(1-((x-Wx)/xWidth));
            
            float yWidth = Sy-Wy;
            y = Wy+(yWidth*angleModifier);
            y-=(yWidth*distModifier)*(1-((y-Wy)/yWidth));
        }
        
        else {
            float xWidth = Nx-Wx;
            x = Wx+(xWidth*angleModifier);
            x-=(xWidth*distModifier)*((x-Wx)/xWidth);
            
            float yWidth = Wy-Ny;
            y = Wy-(yWidth*angleModifier);
            y+=(yWidth*distModifier)*(1-((y-Ny)/yWidth));
        }
        
        CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 4, 4));
    }
}


#pragma mark - Setting up the radar

-(void)setupRadarImages
{
    radarMV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [radarMV setImage:[UIImage imageNamed:@"RadarMV.png"]];
    
    radarBars = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [radarBars setImage:[UIImage imageNamed:@"Radar.png"]];
    [radarBars setAlpha:0.3];
    
    [self addSubview:radarMV];
    [self addSubview:radarBars];
}
-(void)setupSpots:(NSArray*)spots
{
    for (NSDictionary* spot in spots) {
        int angle = [[spot objectForKey:@"angle"] intValue];
        while (angle < 0) angle += 360;
        
        angle += 16; // +16 degrees offset for the non-symetrical positioning (tip is the center)
        angle = (int)fmod(angle, 360);
        
        int dist = [[spot objectForKey:@"distance"] intValue];
        if (dist < 0) dist = 0;
        
        [theSpots setObject:[NSNumber numberWithInt:dist]
                     forKey:[NSNumber numberWithInt:angle]];
    }
}


#pragma mark - Factory Method

- (id)initWithFrame:(CGRect)frame withSpots:(NSArray*)spots
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        theSpots = [NSMutableDictionary dictionary];
        
        [self setupRadarImages];
        [self setupSpots:spots];
        
        [self turnRadar];

    }
    return self;
}


#pragma mark - Moving the radar scanner

#define RADIANS( degrees )      ((degrees)*(M_PI/180))
-(void)turnRadar
{
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(RADIANS(360))];
    rotation.duration = 3;
    rotation.repeatCount = HUGE_VALF;
    [radarMV.layer addAnimation:rotation forKey:@"Spin"];
}

- (void)moveDots:(int)angle
{
    self.transform = CGAffineTransformMakeRotation(-RADIANS(angle));
    radarBars.transform = CGAffineTransformMakeRotation(RADIANS(angle));
}


#pragma mark -- OO Methods

- (NSString *)description {
    return [NSString stringWithFormat: @"ARRadar with %lu dots", (unsigned long)theSpots.count];
}

@end
