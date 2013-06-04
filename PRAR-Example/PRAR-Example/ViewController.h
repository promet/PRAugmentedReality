//
//  ViewController.h
//  PRAR-Example
//
//  Created by Geoffroy Lesage on 5/10/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import "ListView.h"
#import "ARView.h"
#import "MapView.h"

#import "DataController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, ListViewDelegate, ARViewDelegate, MapViewDelegate, DataControllerDelegate> {
    
    DataController *dataController;
    CLLocationManager * locationManager;
    
    IBOutlet UISwitch *prarSwitch;
    IBOutlet UIActivityIndicatorView *loadingI;
    IBOutlet UILabel *statusL;
        
    NSArray *arData;
}

-(IBAction)startPRAR:(id)sender;


@end
