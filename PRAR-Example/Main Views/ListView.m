//
//  ListView.m
//  PrometAR
//
//  Created by Geoffroy Lesage on 4/10/13.
//  Copyright (c) 2013 Promet Solutions Inc. All rights reserved.
//

#import "ListView.h"

#import "DataController.h"


#define ORDER_BY_NAME       0
#define ORDER_BY_DISTANCE   1

#define SORT_VIEW_ANIMATION_DURATION    0.4

#define sortViewUp      CGRectMake(0,-10,320,50)
#define sortViewDown    CGRectMake(0,TOOLBAR_HEIGHT+10,320,50)


@interface ListView ()

@end


@implementation ListView

@synthesize arController;


- (void)alert:(NSString*)title withDetails:(NSString*)details {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:details
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - AR Controller Delegate

- (void)arControllerDidSetupData:(NSDictionary *)arObjects {    
    [loadingProgress setProgress:0.5 animated:YES];
    
    if (arObjectsArray) [arObjects release];
    arObjectsArray = [[NSMutableArray alloc] initWithArray:arObjects.allValues];
    
    [self sortARObjectsArray:ORDER_BY_NAME];
    
    [loadingProgress setProgress:1 animated:YES];
    [loadingI stopAnimating];
}
- (void)arControllerGotUpdatedData {
    [loadingI startAnimating];
    [loadingProgress setProgress:0.0];
    [arController performSelectorInBackground:@selector(setupAllData) withObject:nil];
}

- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details {
    [self alert:problemOrigin withDetails:details];
}


#pragma mark - View Management

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*
    [loadingI startAnimating];
    [loadingProgress setProgress:0.0];
    [arController performSelectorInBackground:@selector(setupAllData) withObject:nil];
     */
    
    [self alert:@"In the works" withDetails:@"This has not yet been updated for this version"];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table Delegate & Datasource

-(void)sortARObjectsArray:(int)orderFilter {
    if (headerTitlesArray) [headerTitlesArray release];
    if (arObjectsDictionary) [arObjectsDictionary release];
    
    headerTitlesArray = [[NSMutableArray alloc] init];
    arObjectsDictionary = [[NSMutableDictionary alloc] init];
    
    NSSortDescriptor *sortDescriptor;
    
    switch (orderFilter) {
        case ORDER_BY_DISTANCE:
            
            for (ARObject *arObject in arObjectsArray) {
                
                float distance = arObject.distance.floatValue;
                NSString *inclusiveMaxDistance;
                
                if (distance < 0.1) {
                    inclusiveMaxDistance = @"<0.1 mi";
                } else if (distance < 0.2) {
                    inclusiveMaxDistance = @"<0.2 mi";
                } else if (distance < 0.3) {
                    inclusiveMaxDistance = @"<0.3 mi";
                } else if (distance < 0.4) {
                    inclusiveMaxDistance = @"<0.4 mi";
                } else if (distance < 0.5) {
                    inclusiveMaxDistance = @"<0.5 mi";
                } else if (distance < 1) {
                    inclusiveMaxDistance = @"<1 mi";
                } else if (distance < 2) {
                    inclusiveMaxDistance = @"<2 mi";
                } else {
                    inclusiveMaxDistance = @"Far away...";
                }
                
                if ([headerTitlesArray containsObject:inclusiveMaxDistance]) {
                    NSMutableArray *currDistanceNum = [arObjectsDictionary objectForKey:inclusiveMaxDistance];
                    [currDistanceNum addObject:arObject];
                    [arObjectsDictionary setObject:currDistanceNum forKey:inclusiveMaxDistance];
                }
                else {
                    [headerTitlesArray addObject:inclusiveMaxDistance];
                    [arObjectsDictionary setObject:[NSMutableArray arrayWithObject:arObject] forKey:inclusiveMaxDistance];
                }
            }
            
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
            break;
                        
        default:
            //Sort by title/name
            
            for (ARObject *arObject in arObjectsArray) {
                NSString *firstLetterOfTitle = [NSString stringWithFormat:@"%c", [arObject.arTitle characterAtIndex:0]];
                
                if ([headerTitlesArray containsObject:firstLetterOfTitle]) {
                    NSMutableArray *currAddressSame = [arObjectsDictionary objectForKey:firstLetterOfTitle];
                    [currAddressSame addObject:arObject];
                    [arObjectsDictionary setObject:currAddressSame forKey:firstLetterOfTitle];
                }
                else {
                    [headerTitlesArray addObject:firstLetterOfTitle];
                    [arObjectsDictionary setObject:[NSMutableArray arrayWithObject:arObject] forKey:firstLetterOfTitle];
                }
            }
            
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arTitle" ascending:YES];
            break;
    }
    
    [headerTitlesArray sortUsingSelector:@selector(compare:)];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    for (NSMutableArray *temp_arObjectsArray in [arObjectsDictionary allValues]) {
        [temp_arObjectsArray sortUsingDescriptors:sortDescriptors];
    }
    [sortDescriptor release];
    
    [_tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected");
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
    }
    
    ARObject *arObject = [[arObjectsDictionary objectForKey:[headerTitlesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = arObject.arTitle;
    cell.detailTextLabel.text = arObject.address;
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[arObjectsDictionary objectForKey:[headerTitlesArray objectAtIndex:section]] count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return headerTitlesArray.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [headerTitlesArray objectAtIndex:section];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!sortView.hidden) {
        [sortView setFrame:sortViewDown];
        [UIView beginAnimations:@"hideSortView" context:nil];
        [UIView setAnimationDuration:0.2];
        [sortView setFrame:sortViewUp];
        [UIView commitAnimations];
        [self performSelector:@selector(hideSortView) withObject:nil afterDelay:0.3];
    }
}


#pragma mark - Button Actions

- (void)hideSortView {
    [sortView setHidden:YES];
}
- (IBAction)sort:(id)sender {
    if (sortView.hidden) {
        [sortView setFrame:sortViewUp];
        [sortView setHidden:NO];
        [UIView beginAnimations:@"dropSortView" context:nil];
        [UIView setAnimationDuration:SORT_VIEW_ANIMATION_DURATION];
        [sortView setFrame:sortViewDown];
        [UIView commitAnimations];
    } else {
        [sortView setFrame:sortViewDown];
        [UIView beginAnimations:@"hideSortView" context:nil];
        [UIView setAnimationDuration:SORT_VIEW_ANIMATION_DURATION];
        [sortView setFrame:sortViewUp];
        [UIView commitAnimations];
        [self performSelector:@selector(hideSortView) withObject:nil afterDelay:SORT_VIEW_ANIMATION_DURATION];
    }
}
- (IBAction)orderBy:(id)sender {
    [self sortARObjectsArray:[(UISegmentedControl*)sender selectedSegmentIndex]];
}
- (IBAction)done:(id)sender {
    [arObjectsDictionary release];
    [arObjectsArray release];
    [headerTitlesArray release];
    
    [arController release];
    [_tableView release];
    
    [loadingI release];
    [loadingProgress release];
    [sortView release];
    
    [self.delegate listViewControllerDidFinish:self];
}

@end
