//
//  ViewController.h
//  PRAR-Example
//
//  Created by ANDREW KUCHARSKI on 5/10/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import "ListView.h"
#import "ARView.h"
#import "MapView.h"

@interface ViewController : UIViewController <ListViewDelegate, ARViewDelegate, MapViewDelegate> {
    
    ARController *arController;
    
    IBOutlet UISwitch *prarSwitch;
}

@property (nonatomic, retain) ARController *arController;

-(IBAction)startPRAR:(id)sender;


@end
