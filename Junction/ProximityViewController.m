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
#import "PortraitScrollView.h"
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
@synthesize photoView, nameLabel, descLabel;
//@synthesize names, titles, photos, distances;
@synthesize myUserInfo;
@synthesize delegate;
@synthesize userInfos;
@synthesize distanceGroups;
@synthesize portraitViews;
@synthesize headerViews;

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
}

-(void)updateMyUserInfo {
    myUserInfo = [delegate getMyUserInfo];
    [nameLabel setText:myUserInfo.username];
    [photoView setImage:myUserInfo.photo];
    [descLabel setText:myUserInfo.headline];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
-(void)addUser:(NSString *)userID withName:(NSString *)name withHeadline:(NSString *)headline withPhoto:(UIImage *)photo atDistance:(double)distance {    
    UserInfo * newUser = [[UserInfo alloc] init];
    [newUser setUsername:name];
    [newUser setHeadline:headline];
    [newUser setPhoto:(photo? photo:[UIImage imageNamed:@"graphic_nopic"])];
    [userInfos setObject:newUser forKey:userID];
    for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
        if (distance < DISTANCE_BOUNDARIES[i]) {
            [[distanceGroups objectAtIndex:i] addObject:userID];
            break;
        }
    }
    
    [tableView reloadData];
}
 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // may have more than one distance -> sections
    return MAX_DISTANCE_GROUPS;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case CLOSE:
            return @"Really close by";
            break;
        
        case ROOM:
            return [NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[ROOM]];
            break;
            
        case BALLROOM:
            return [NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[BALLROOM]];
            break;

        case BALLPARK:
            return [NSString stringWithFormat:@"Within %d meters", DISTANCE_BOUNDARIES[BALLPARK]];
            break;

        case DISTANT:
            return [NSString stringWithFormat:@"Beyond %d meters", DISTANCE_BOUNDARIES[BALLPARK]];
            break;

        case INFINITE:
            return [NSString stringWithFormat:@"Infinity and beyond"];
            break;
    
        default:
            break;
    }
    return nil;
}
*/

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([[distanceGroups objectAtIndex:section] count] == 0)
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
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
    //NSLog(@"Rows %f ct %d", rows, ct);
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[distanceGroups objectAtIndex:section] count] == 0)
        return 1.0;
    return HEADER_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return ROW_HEIGHT;
    if ([[distanceGroups objectAtIndex:indexPath.section] count] == 0)
        return 0;
    return self.view.bounds.size.width / NUM_COLUMNS;
}

// 1 column cell
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(ROW_HEIGHT, 5, 300, 25)];
        UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(ROW_HEIGHT, 23, 300, 20)];
		topLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]-4];
		bottomLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		bottomLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize] - 7];
        
        UIButton * photo = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, ROW_HEIGHT-10, ROW_HEIGHT-10)];
		[photo.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photo.layer setBorderWidth: 2.0];
        [photo addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        photo.tag = PHOTO_TAG; // + [indexPath row];
        [cell.contentView addSubview:photo];
        
        //NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        topLabel.tag = TOP_LABEL_TAG;
        bottomLabel.tag = BOTTOM_LABEL_TAG;
        [cell.contentView addSubview:topLabel];
        [cell.contentView addSubview:bottomLabel];
        [cell addSubview:cell.contentView];
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int index = [indexPath row];
    
    NSMutableArray * distanceGroup = [distanceGroups objectAtIndex:section];
    
    NSString * username;
    if (index >= [distanceGroup count])
        [cell.textLabel setText:@"NIL"];
    else {
        NSString * userID = [distanceGroup objectAtIndex:index];
        UserInfo * userInfo = [userInfos objectForKey:userID];
        
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
        username = userInfo.username; //[names objectAtIndex:index];
        NSString * desc = userInfo.headline; //[titles objectAtIndex:index];
        [topLabel setText:username];
        [bottomLabel setText:desc];
        [topLabel setFrame:CGRectMake(ROW_HEIGHT, 5, 300, 25)]; // bottom label exists so set topLabel higher

        UIImage * img = userInfo.photo; //[photos objectAtIndex:index];
        UIButton * photo = (UIButton*)[cell viewWithTag:PHOTO_TAG]; // + index];
        //[photo setBackgroundImage:img forState:UIControlStateNormal]; //setImage:img forState:UIControlStateNormal];
        [photo setImage:img forState:UIControlStateNormal];
        photo.titleLabel.text = username;
        photo.titleLabel.hidden = YES;
    }    

    if (0) {
        UIImageView * addFriendButton = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 91, 30)];
        [addFriendButton setImage:[UIImage imageNamed:@"btn_follow"]];// forState:
        cell.accessoryView = addFriendButton;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;    
}
*/

-(UIView*)viewForItemInSection:(int)section Row:(int)row Column:(int)column {
    NSMutableArray * group = [distanceGroups objectAtIndex:section];
    int index = row * NUM_COLUMNS + column;
    //NSLog(@"Section %d row %d col %d index %d count %d", section, row, column, index, [group count]);
    if (index >= [group count])
        return nil;
    NSString * userID = [group objectAtIndex:index];
    
    if (![portraitViews objectForKey:userID]) {
        // create new portraitView
        if ([userInfos objectForKey:userID]) {
            int size = self.view.bounds.size.width / NUM_COLUMNS;
            int xoffset = column * size;
            CGRect frame = CGRectMake(xoffset, 0, size, size);
            PortraitScrollViewController * portraitView = [[PortraitScrollViewController alloc] init];
            [portraitView.view setFrame:frame];
            [portraitView addUserInfo:[userInfos objectForKey:userID]];
            [portraitViews setObject:portraitView forKey:userID];
        }
    }
    return [[portraitViews objectForKey:userID] view];
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
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    // Configure the cell...
    for (UIView * subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    int section = [indexPath section];
    int row = [indexPath row];
    
    for (int col=0; col<NUM_COLUMNS; col++) {
        UIView * portraitView = [self viewForItemInSection:section Row:row Column:col];
        [cell addSubview:portraitView];
    }
    return cell;
}

-(void)didClickUserPhoto:(id)sender {
    NSLog(@"Clicked on some photo.");
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
        if ([userID isEqualToString:myUserInfo.pfUserID])
            return;

        // todo: use that to calculate distance, requires own coordinate from gps
        float distanceInMeters = 999;
        if (appDelegate.lastLocation) {
            CLLocation * friendLocation = [[CLLocation alloc] initWithLatitude:pulse.coordinate.latitude longitude:pulse.coordinate.longitude];
            distanceInMeters = [appDelegate.lastLocation distanceFromLocation:friendLocation];
        }
        else {
            NSLog(@"No last location!");
        }
        
        NSLog(@"You are at %f %f: %@ %@ found at coord %f %f distance %f", appDelegate.lastLocation.coordinate.latitude, appDelegate.lastLocation.coordinate.longitude, friendUserInfo.username, userID, pulse.coordinate.latitude, pulse.coordinate.longitude, distanceInMeters);
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
}
@end
