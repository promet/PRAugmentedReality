//
//  ViewController.h
//  PRAR-Simple
//
//  Created by Jeff on 3/27/14.
//  Copyright (c) 2014 GeoffroyLesage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PRARManager.h>

@interface ViewController : UIViewController <PRARManagerDelegate>
{
    IBOutlet UIView *loadingV;
}

@end
