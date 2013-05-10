//
//  ListView.h
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARController.h"


@class ListView;

@protocol ListViewDelegate
- (void)listViewControllerDidFinish:(ListView *)controller;
@end


@interface ListView : UIViewController <ARControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    ARController *arController;
    
    IBOutlet UITableView *_tableView;
    
    NSMutableDictionary *arObjectsDictionary;
    NSMutableArray *arObjectsArray;
    NSMutableArray *headerTitlesArray;
    
    IBOutlet UIActivityIndicatorView *loadingI;
    IBOutlet UIProgressView *loadingProgress;
    IBOutlet UIView *sortView;
}

@property (assign, nonatomic) id <ListViewDelegate> delegate;
@property (nonatomic, retain) ARController *arController;

- (IBAction)sort:(id)sender;
- (IBAction)orderBy:(id)sender;
- (IBAction)done:(id)sender;

@end

