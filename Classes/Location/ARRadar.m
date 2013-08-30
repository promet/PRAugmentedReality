//
//  ARRadar.m
//  PRAR-Example
//
//  Created by ANDREW KUCHARSKI on 8/29/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import "ARRadar.h"

#import <QuartzCore/QuartzCore.h>

@interface ARRadar ()

@end

@implementation ARRadar


#pragma mark - Drawing Override
- (void)drawRect:(CGRect)rect {
    
    if (theSpots.count < 1) return;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(contextRef, 0.2, 1, 0.2, 0.8);
    
    int max = [[[theSpots allValues] valueForKeyPath:@"@max.intValue"] intValue];
    int min = [[[theSpots allValues] valueForKeyPath:@"@min.intValue"] intValue];
    
    int x = 0;
    int y = 0;
    
    for (NSNumber *angle in [theSpots allKeys]) {
        
        // Angle modifier//
        int angleF = (int)fmod(angle.doubleValue, 360);
        float angleModifier = fmod(angleF,90)/90.0;
        
        // Distance modifier //
        float distModifier = 0;
        if ([[theSpots objectForKey:angle] intValue] != min) {
            distModifier = 1-(([[theSpots objectForKey:angle] floatValue]-min)/(max-min));
        }
        
#define Nx  49
#define Ny  10
#define Ex  85
#define Ey  48
#define Sx  49
#define Sy  85
#define Wx  10
#define Wy  48
        
        // Positioning on axis //
        if (angleF < 90) {
            float xWidth = Ex-Nx;
            x = Nx+(xWidth*angleModifier);
            x-=(xWidth*distModifier)*((x-Nx)/xWidth);
            
            float yWidth = Ey-Ny;
            y = Ny+(yWidth*angleModifier);
            y+=(yWidth*distModifier)*(1-((y-Ny)/yWidth));
        }
        else if (angleF < 180) {
            float xWidth = Ex-Sx;
            x = Ex-(xWidth*angleModifier);
            x-=(xWidth*distModifier)*((x-Sx)/xWidth);
            
            float yWidth = Sy-Ey;
            y = Ey+(yWidth*angleModifier);
            y-=(yWidth*distModifier)*((y-Ey)/yWidth);
        }
        
        else if (angleF < 270) {
            float xWidth = Sx-Wx;
            x = Sx-(xWidth*angleModifier);
            x+=(xWidth*distModifier)*(1-((x-Wx)/xWidth));
            
            float yWidth = Sy-Wy;
            y = Sy-(yWidth*angleModifier);
            y-=(yWidth*distModifier)*((y-Wy)/yWidth);
        }
        
        else {
            float xWidth = Nx-Wx;
            x = Wx+(xWidth*angleModifier);
            x+=(xWidth*distModifier)*(1-((x-Wx)/xWidth));
            
            float yWidth = Wy-Ny;
            y = Wy-(yWidth*angleModifier);
            y+=(yWidth*distModifier)*(1-((y-Ny)/yWidth));
        }
        
        CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 4, 4));
    }
}


-(void)setupRadarImages {
    radarMV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [radarMV setImage:[UIImage imageNamed:@"RadarMV.png"]];
    
    UIImageView *bars = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [bars setImage:[UIImage imageNamed:@"Radar.png"]];
    [bars setAlpha:0.3];
    
    [self addSubview:radarMV];
    [self addSubview:bars];
}
-(void)setupSpots:(NSArray*)spots {
    for (NSDictionary* spot in spots) {
        int x = [[spot objectForKey:@"angle"] intValue];
        if (x > 360) x-= 360;
        if (x < 0) x+= 360;
        
        int dist = [[spot objectForKey:@"distance"] intValue];
        if (dist < 0) dist = 0;
        
        [theSpots setObject:[NSNumber numberWithInt:x]
                     forKey:[NSNumber numberWithInt:dist]];
    }
}

#pragma mark - Factory Method
- (id)initWithFrame:(CGRect)frame withSpots:(NSArray*)spots {
    
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

#define RADIANS( degrees )      ((degrees)*(M_PI/180))
-(void)turnRadar {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(RADIANS(360))];
    rotation.duration = 3;
    rotation.repeatCount = HUGE_VALF;
    [radarMV.layer addAnimation:rotation forKey:@"Spin"];
}

- (void)moveDots:(int)angle {
    //NSLog(@"move to %d", angle);
}


@end
