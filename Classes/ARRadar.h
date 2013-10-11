//
//  ARRadar.h
//  PRAR-Example
//
//  Created by ANDREW KUCHARSKI on 8/29/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARRadar : UIView
{
    UIImageView *radarMV;
    UIImageView *radarBars;
    NSMutableDictionary *theSpots;
}

- (id)initWithFrame:(CGRect)frame withSpots:(NSArray*)spots;

- (void)moveDots:(int)angle;

@end
