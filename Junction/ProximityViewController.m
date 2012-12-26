//
//  ProximityViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProximityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h" // for notification constants
#import "UserPulse.h"
#import "PortraitScrollViewController.h"

const int DISTANCE_BOUNDARIES[MAX_DISTANCE_GROUPS] = {
    10,
    30,
    100,
    500, // BALLPARK
    9999, // DISTANT
    1e7 // infinity == greater than US
};


@interface ProximityViewController ()

@end

@implementation ProximityViewController

@synthesize activityIndicator;
@synthesize tableView;
//@synthesize photoView, nameLabel, descLabel;
//@synthesize names, titles, photos, distances;
@synthesize myUserInfo;
@synthesize userInfos;
@synthesize distanceGroups;
@synthesize portraitViews;
@synthesize headerViews;
@synthesize showConnectionsOnly;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_friends"]];
//        [self.tabBarItem setTitle:@"Nearby"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*
    names = [[NSMutableArray alloc] init];
    titles = [[NSMutableArray alloc] init];
    photos = [[NSMutableArray alloc] init];
    distances = [[NSMutableArray alloc] init];
     */
    userInfos = [[NSMutableDictionary alloc] init];
    distanceGroups = [[NSMutableArray alloc] init];
    portraitViews = [[NSMutableDictionary alloc] init];
    headerViews = [[NSMutableDictionary alloc] init];
    for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
        [distanceGroups addObject:[[NSMutableArray alloc] init]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateMyUserInfo) 
                                                 name:kMyUserInfoDidChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:activityIndicator 
                                             selector:@selector(startAnimating) 
                                                 name:kParseFriendsStartedUpdatingNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:activityIndicator 
                                             selector:@selector(stopAnimating) 
                                                 name:kParseFriendsFinishedUpdatingNotification 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:kMyUserInfoDidChangeNotification  
                                                  object:nil];
}
-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:kMyUserInfoDidChangeNotification  
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator    
                                                    name:kParseFriendsStartedUpdatingNotification  
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator    
                                                    name:kParseFriendsFinishedUpdatingNotification  
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateMyUserInfo];
//    [self.tableView reloadData];
    [self reloadAll];
}

-(void)updateMyUserInfo {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    myUserInfo = [appDelegate myUserInfo];
//    [nameLabel setText:myUserInfo.username];
//    [photoView setImage:myUserInfo.photo];
//    [descLabel setText:myUserInfo.headline];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // may have more than one distance -> sections
    return MAX_DISTANCE_GROUPS;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //if ([[distanceGroups objectAtIndex:section] count] == 0)
    //    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    if ([headerViews objectForKey:[NSNumber numberWithInt:section]] == nil) {
        CGRect frame = CGRectMake(5, 0, self.view.bounds.size.width-10, HEADER_HEIGHT);
        UILabel * label = [[UILabel alloc] initWithFrame:frame];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:16]];
        [label setBackgroundColor:[UIColor blackColor]];
        switch (section) {
            case CLOSE:
                [label setText:@"Really close by"];
                break;
                
            case ROOM:
                [label setText:[NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[ROOM]]];
                break;
                
            case BALLROOM:
                [label setText: [NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[BALLROOM]]];
                break;
                
            case BALLPARK:
                [label setText: [NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[BALLPARK]]];
                break;
                
            case DISTANT:
                [label setText: [NSString stringWithFormat:@"Beyond %d meters", DISTANCE_BOUNDARIES[BALLPARK]]];
                break;
                
            case INFINITE:
                [label setText: [NSString stringWithFormat:@"Infinity and beyond"]];
                break;
                
            default:
                [label setText:@""];
                break;
        }
        UIView * headerView = [[UIView alloc] initWithFrame:frame];
        [headerView addSubview:label];
        [headerView setBackgroundColor:[UIColor blackColor]];
        [headerViews setObject:headerView forKey:[NSNumber numberWithInt:section]];
    }
    return [headerViews objectForKey:[NSNumber numberWithInt:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    float ct = ((float)[[distanceGroups objectAtIndex:section] count]);
    float rows = ceil( ct / NUM_COLUMNS);
    NSLog(@"Distance group: %d count: %d rows: %f", [distanceGroups count], [[distanceGroups objectAtIndex:section] count], rows);
    //return [[distanceGroups objectAtIndex:section] count];
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if ([[distanceGroups objectAtIndex:section] count] == 0)
//        return 1.0;
    return HEADER_HEIGHT;
}
/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
//    return 30;
}
*/
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if ([[distanceGroups objectAtIndex:indexPath.section] count] == 0)
    //    return 0;
    float height = self.tableView.frame.size.width / NUM_COLUMNS;
    NSLog(@"Row height for section %d row %d: %f", indexPath.section, indexPath.row, height);
    return height;
}

-(UIView*)viewForItemInSection:(int)section Row:(int)row Column:(int)column {
    NSMutableArray * group = [distanceGroups objectAtIndex:section];
    int index = row * NUM_COLUMNS + column;
    if (index >= [group count])
        return nil;
    NSString * userID = [group objectAtIndex:index];
    NSLog(@"Section %d row %d col %d index %d count %d userID %@", section, row, column, index, [group count], userID);
    
    if (![portraitViews objectForKey:userID]) {
        // create new portraitView
        if ([userInfos objectForKey:userID]) {
            int size = self.tableView.frame.size.width / NUM_COLUMNS;
            CGRect frame = CGRectMake(0, 0, size, size);
            PortraitScrollViewController * portraitView = [[PortraitScrollViewController alloc] init];
            [portraitView setDelegate:self];
            [portraitView.view setFrame:frame]; // for setting photo size
            [portraitView addUserInfo:[userInfos objectForKey:userID]];
            
            [portraitViews setObject:portraitView forKey:userID];
        }
    }
    return [[portraitViews objectForKey:userID] view];
    //return [portraitViews objectForKey:userID];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setBackgroundColor:[UIColor yellowColor]];
    }
    
    // Configure the cell...
    for (UIView * subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    int section = [indexPath section];
    int row = [indexPath row];
    
    for (int col=0; col<NUM_COLUMNS; col++) {
        UIView * portraitView = [self viewForItemInSection:section Row:row Column:col];
        int size = self.tableView.frame.size.width / NUM_COLUMNS;
        int xoffset = col * size;
        CGRect frame = CGRectMake(xoffset, 0, size, size);
        [portraitView setFrame:frame];
        [cell addSubview:portraitView];
        //NSLog(@"Cell row %d col %d frame: %f %f %f %f", row, col, portraitView.frame.origin.x, portraitView.frame.origin.y, portraitView.frame.size.width, portraitView.frame.size.height);
    }
    return cell;
}

-(void)didTapPortraitWithUserInfo:(UserInfo *)tappedUserInfo {
    NSLog(@"Clicked on portrait with userInfo: %@", tappedUserInfo.pfUserID);
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate displayUserWithUserInfo:tappedUserInfo];
}

-(void)reloadAll {
    NSLog(@"***Reloading all in proximityView!***");
    //[userInfos removeAllObjects];
    //for (NSMutableArray * group in distanceGroups) {
    //    [group removeAllObjects];
    //}
    // all Junction users
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray * allUserInfos = [appDelegate allJunctionUserInfos];
    NSMutableDictionary * allPulses = [appDelegate allPulses];
    for (UserInfo * friendUserInfo in allUserInfos) {
        NSString * userID = friendUserInfo.pfUserID;
        UserPulse * pulse = [allPulses objectForKey:userID];
#if !TESTING
        if ([userID isEqualToString:myUserInfo.pfUserID])
            return;
#endif
        
        if (showConnectionsOnly) {
            if ([appDelegate isConnectedWithUser:friendUserInfo])
                NSLog(@"is connected!");
            else {
                continue;
            }
        }
        
        // todo: use that to calculate distance, requires own coordinate from gps
        float distanceInMeters = 999;
        if (appDelegate.lastLocation) {
            CLLocation * friendLocation = [[CLLocation alloc] initWithLatitude:pulse.coordinate.latitude longitude:pulse.coordinate.longitude];
            distanceInMeters = [appDelegate.lastLocation distanceFromLocation:friendLocation];
        }
        else {
            NSLog(@"No last location!");
        }
        
        //NSLog(@"You are at %f %f: %@ %@ found at coord %f %f distance %f", appDelegate.lastLocation.coordinate.latitude, appDelegate.lastLocation.coordinate.longitude, friendUserInfo.username, userID, pulse.coordinate.latitude, pulse.coordinate.longitude, distanceInMeters);
        [userInfos setObject:friendUserInfo forKey:userID];
        for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
            NSMutableArray * group = [distanceGroups objectAtIndex:i];
            if ([group containsObject:userID]) {
                [group removeObject:userID];
            }
        }
        for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
            NSMutableArray * group = [distanceGroups objectAtIndex:i];
            if (distanceInMeters < DISTANCE_BOUNDARIES[i]) {
                [group addObject:userID];
                NSLog(@"Added %@ to distance %d, now %d users here", friendUserInfo.username, DISTANCE_BOUNDARIES[i], [group count]);
                break;
            }
        }
    }
    
    [self.tableView reloadData];
    /*
    // remove groups as necessary
    for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
        NSMutableArray * group = [distanceGroups objectAtIndex:i];
        if ([group count] == 0) {
            [self.tableView beginUpdates];
            //[myArray removeObjectAtIndex:myIndexPath.section];
            //[myArrayAnswerCount removeObjectAtIndex:myIndexPath.section]; //this is what i forgot.
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:YES];
            [self.tableView endUpdates];
        }
    }
     */
}

-(IBAction)didClickSearch:(id)sender {
    NSLog(@"Proximity view clicked search");
}

/*
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int size = self.tableView.frame.size.width / NUM_COLUMNS;
}
 */
@end
