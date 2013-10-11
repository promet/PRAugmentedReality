//
//  ViewController.h
//  PRAR-Example
//
//  Created by ANDREW KUCHARSKI on 6/5/13.
//  Copyright (c) 2013 Geoffroy Lesage. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "ARView.h"
#import "DataController.h"

@interface ViewController : UIViewController <ARViewDelegate, DataControllerDelegate, MKMapViewDelegate>
{
    
    DataController *dataController;
    IBOutlet MKMapView *_mapView;
    
    IBOutlet UIActivityIndicatorView *loadingI;
    
    IBOutlet UILabel *statusLL;
    IBOutlet UISwitch *prarSwitchL;
    IBOutlet UIButton *arBL;
    
    IBOutlet UILabel *statusLP;
    IBOutlet UISwitch *prarSwitchP;
    IBOutlet UIButton *arBP;
    
    IBOutlet UIView *portraitControls;
    IBOutlet UIView *landscapeControls;
    
    NSArray *arData;
    
    NSTimer *locRefreshTimer;
}

-(IBAction)startPRAR:(id)sender;


@end
