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
    10  ,
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
@synthesize distanceGroupsIDSets, distanceGroupsOrdered, distanceGroupsOrderedFiltered;
@synthesize portraitViews, portraitLoaded;
@synthesize headerViews;
@synthesize showConnectionsOnly;
@synthesize filterViewController;

// pull to refresh
@synthesize reloading=_reloading;
@synthesize refreshHeaderView;
@synthesize hasHeaderRow;
@synthesize searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar-browse"]];
        [self.tabBarItem setTitle:@"Browse"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIImage * headerbg = [UIImage imageNamed:@"header_bg"];
    [self.navigationController.navigationBar setBackgroundImage:headerbg forBarMetrics:UIBarMetricsDefault];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [titleView setFont:[UIFont boldSystemFontOfSize:23]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:158.0/255.0 blue:205.0/255.0 alpha:1]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    self.navigationItem.titleView = titleView;
    
    if (!showConnectionsOnly) {
        // browse tab
        //self.navigationItem.title = @"Junction";
        titleView.text = @"Junction";
    }
    else {
        // connections tab
        //self.navigationItem.title = @"Connections";
        titleView.text = @"Connections";
    }
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 26, 26)];
    [button setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickSearch:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    
    self.searchButton = button;
    
    /*
    names = [[NSMutableArray alloc] init];
    titles = [[NSMutableArray alloc] init];
    photos = [[NSMutableArray alloc] init];
    distances = [[NSMutableArray alloc] init];
     */
    userInfos = [[NSMutableDictionary alloc] init];
    distanceGroupsIDSets = [[NSMutableArray alloc] init];
    distanceGroupsOrdered = [[NSMutableArray alloc] init];
    distanceGroupsOrderedFiltered = [[NSMutableArray alloc] init];
    portraitViews = [[NSMutableDictionary alloc] init];
    portraitLoaded = [[NSMutableDictionary alloc] init];
    headerViews = [[NSMutableDictionary alloc] init];
    for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
        [distanceGroupsIDSets addObject:[[NSMutableArray alloc] init]];
        [distanceGroupsOrdered addObject:[[NSMutableArray alloc] init]];
        [distanceGroupsOrderedFiltered addObject:[[NSMutableArray alloc] init]];
    }
    
    if (refreshHeaderView == nil) {
        /*
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
//        view.delegate = self;
        [view setBackgroundColor:[UIColor blackColor]];
        [tableView addSubview:view];
        refreshHeaderView = view;
         */
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
        refreshHeaderView.bottomBorderThickness = 0.0;
        [self.tableView addSubview:refreshHeaderView];
    }
    //  update the last update date
//    [refreshHeaderView refreshLastUpdatedDate];

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsUpdated
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
    [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator
                                                    name:kParseConnectionsUpdated
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

-(void)updateConnections {
    // show new people connections in Connections tab
    // also change blurriness in proximity tab
    [self reloadAll];
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
    if ([[distanceGroupsIDSets objectAtIndex:section] count] == 0)
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    if ([headerViews objectForKey:[NSNumber numberWithInt:section]] == nil) {
        CGRect frame = CGRectMake(5, 0, self.view.bounds.size.width-10, HEADER_HEIGHT);
        UILabel * label = [[UILabel alloc] initWithFrame:frame];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:12]];
        [label setBackgroundColor:[UIColor clearColor]];
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
        frame = CGRectMake(0, 0, self.view.bounds.size.width, HEADER_HEIGHT);
        UIView * bgView = [[UIView alloc] initWithFrame:frame];
        [bgView setBackgroundColor:[UIColor colorWithRed:83.0/255.0 green:114.0/255.0 blue:142.0/255.0 alpha:1]];//[UIColor blackColor]];
        [bgView setAlpha:.75];
        UIView * headerView = [[UIView alloc] initWithFrame:frame];
        [headerView addSubview:bgView];
        [headerView addSubview:label];
        [headerView setBackgroundColor:[UIColor clearColor]];
        [headerViews setObject:headerView forKey:[NSNumber numberWithInt:section]];
    }
    return [headerViews objectForKey:[NSNumber numberWithInt:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    float ct = ((float)[[distanceGroupsIDSets objectAtIndex:section] count]);
    if (self.filterViewController.industryFilter || self.filterViewController.companyFilter || self.filterViewController.friendsFilter) {
        NSMutableArray * groupOrdered = [distanceGroupsOrderedFiltered objectAtIndex:section];
        ct = [groupOrdered count];
    }
    float rows = ceil( ct / NUM_COLUMNS);
    //NSLog(@"Distance group: %d count: %d rows: %f", [distanceGroups count], [[distanceGroups objectAtIndex:section] count], rows);
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[distanceGroupsIDSets objectAtIndex:section] count] == 0)
        return 0.0;
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
    //NSLog(@"Row height for section %d row %d: %f", indexPath.section, indexPath.row, height);
    return height;
}

-(UIView*)viewForItemInSection:(int)section Row:(int)row Column:(int)column {
    NSMutableArray * groupIDs = [distanceGroupsIDSets objectAtIndex:section];
    NSMutableArray * groupOrdered = [distanceGroupsOrdered objectAtIndex:section];
    if (self.filterViewController.industryFilter || self.filterViewController.companyFilter || self.filterViewController.friendsFilter)
        groupOrdered = [distanceGroupsOrderedFiltered objectAtIndex:section];
    
    int index = row * NUM_COLUMNS + column;
    if (index >= [groupIDs count] || index >= [groupOrdered count])
        return nil;
    OrderedUser * ordered = [groupOrdered objectAtIndex:index];
    NSString * userID = ordered.userInfo.pfUserID;
    //NSLog(@"Section %d row %d col %d index %d count %d userID %@", section, row, column, index, [group count], userID);
    
    if (![portraitViews objectForKey:userID] || ![portraitLoaded objectForKey:userID]) {
        // create new portraitView
        UserInfo * userInfo = [userInfos objectForKey:userID];
        if (userInfo) {
            int size = self.tableView.frame.size.width / NUM_COLUMNS;
            CGRect frame = CGRectMake(0, 0, size, size);
            PortraitScrollViewController * portraitView = [[PortraitScrollViewController alloc] init];
            [portraitView setDelegate:self];
            [portraitView.view setFrame:frame]; // for setting photo size
            NSLog(@"AddUserInfo for user %@ id %@", userInfo.username, userID);
            [portraitView addUserInfo:userInfo];
            
            [portraitViews setObject:portraitView forKey:userID];
            [portraitLoaded setObject:[NSNumber numberWithBool:YES] forKey:userID];
        }
        else {
            NSLog(@"Could not addUserInfo for userID %@", userID);
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
        [cell.contentView setBackgroundColor:[UIColor redColor]];
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
    if (tappedUserInfo.pfUserID == nil)
        NSLog(@"Here!");
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate displayUserWithUserInfo:tappedUserInfo forChat:NO];
}

-(void)reloadUserPortrait:(UserInfo*)friendUserInfo withPulse:(UserPulse*)pulse {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // because each user portrait gets loaded asynchronously, we have to reset the pull to refresh each time. there is no real moment for "finished loading data".
    [self dataSourceDidFinishLoadingNewData];

    NSString * userID = friendUserInfo.pfUserID;
    
    if (showConnectionsOnly) {
        if ([userID isEqualToString:myUserInfo.pfUserID])
            return;
        if ([appDelegate isConnectedWithUser:friendUserInfo])
            NSLog(@"is connected!");
        else {
            return;
        }
    }
    
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
        NSMutableArray * groupIDs = [distanceGroupsIDSets objectAtIndex:i];
        if ([groupIDs containsObject:userID]) {
            [self removeUser:friendUserInfo fromGroup:i];
        }
    }
    for (int i=0; i<MAX_DISTANCE_GROUPS; i++) {
        if (distanceInMeters < DISTANCE_BOUNDARIES[i]) {
            [self addUser:friendUserInfo atDistance:distanceInMeters forGroup:i];
            //NSLog(@"Added %@ to distance %d, now %d users here", friendUserInfo.username, DISTANCE_BOUNDARIES[i], [group count]);
            break;
        }
    }
    [self.tableView reloadData];
}

-(void)addUser:(UserInfo*)friendUserInfo atDistance:(float)distance forGroup:(int)groupIndex {
    NSString * userID = friendUserInfo.pfUserID;
    NSMutableArray * groupIDs = [distanceGroupsIDSets objectAtIndex:groupIndex];
    NSMutableArray * groupOrdered = [distanceGroupsOrdered objectAtIndex:groupIndex];
    [groupIDs addObject:userID];
    OrderedUser * orderedUser = [[OrderedUser alloc] initWithUserInfo:friendUserInfo];
    if ([userID isEqualToString:myUserInfo.pfUserID])
        distance = 0;
    [orderedUser setWeight:distance];
    for (int i=0; i<[groupOrdered count]; i++) {
        OrderedUser * oldUser = [groupOrdered objectAtIndex:i];
        if ([orderedUser compare:oldUser] == NSOrderedAscending || [orderedUser compare:oldUser] == NSOrderedSame) {
            [groupOrdered insertObject:orderedUser atIndex:i];
            /*
            NSLog(@"Added ordered user %@ at weight %f to position %d", orderedUser.userInfo.username, orderedUser.weight, i);
            int ct = 0;
            for (OrderedUser * user in groupOrdered) {
                NSLog(@"  user %d: %@ weight %f", ct++, user.userInfo.username, user.weight);
            }
             */
            return;
        }
    }
    [groupOrdered addObject:orderedUser];
    NSLog(@"Added ordered user %@ at weight %f to position %d", orderedUser.userInfo.username, orderedUser.weight, [groupOrdered count]-1);
}

-(void)removeUser:(UserInfo*)friendUserInfo fromGroup:(int)groupIndex {
    NSString * userID = friendUserInfo.pfUserID;
    NSMutableArray * groupIDs = [distanceGroupsIDSets objectAtIndex:groupIndex];
    NSMutableArray * groupOrdered = [distanceGroupsOrdered objectAtIndex:groupIndex];
    [groupIDs removeObject:userID];
    for (OrderedUser * user in groupOrdered) {
        if ([user.userInfo.pfUserID isEqualToString:userID]) {
            [groupOrdered removeObject:user];
            return;
        }
    }
    if ([groupOrdered count] != [groupIDs count]) {
        int ct = 0;
        for (OrderedUser * user in groupOrdered) {
            NSLog(@"user %d: %@ %@ userID %@", ct++, user.userInfo.username, user.userInfo.pfUserID, userID);
        }
        NSLog(@"WUT");
    }
}

-(void)reloadAllUserInfo {
    // all Junction users
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray * allUserInfos = [appDelegate allJunctionUserInfos];
    NSMutableDictionary * allPulses = [appDelegate allPulses];

    for (UserInfo * friendUserInfo in allUserInfos) {
        UserPulse * pulse = [allPulses objectForKey:friendUserInfo.pfUserID];
        [self reloadUserPortrait:friendUserInfo withPulse:pulse];
    }
}

-(void)reloadAll {
    [self.portraitViews removeAllObjects];
    [self.portraitLoaded removeAllObjects]; // force reload of all portraits but don't clear portraitViews
    [self reloadAllUserInfo];
    [self dataSourceDidFinishLoadingNewData];
}

-(IBAction)didClickSearch:(id)sender {
    NSLog(@"Proximity view clicked search");
    if (!isFilterShowing) {
        [self toggleFilterView:YES];
    }
    else {
        [self toggleFilterView:NO];
    }
}

-(void)refreshProximity {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate getJunctionUsers];
    [appDelegate forcePulse];
}

-(void)toggleFilterView:(BOOL)show {
    if (!self.filterViewController) {
        self.filterViewController = [[FilterViewController alloc] init];
        [self.filterViewController setDelegate:self];
        [self.view addSubview:self.filterViewController.view];
    }
    
    isFilterShowing = show;
    if (show) {
        [self.filterViewController.view setHidden:NO];
    }
    else {
        [self.filterViewController.view setHidden:YES];
    }
}

#pragma mark FilterDelegate

-(void)closeFilter {
    [self toggleFilterView:NO];
}

-(void)doFilter {
    NSLog(@"Filters: industry %@ company %@ friends %d", self.filterViewController.industryFilter, self.filterViewController.companyFilter, self.filterViewController.friendsFilter);
    
    NSString * company = [self.filterViewController.companyFilter lowercaseString];
    NSString * industry = [self.filterViewController.industryFilter lowercaseString];

    for (int i=0; i<[distanceGroupsOrdered count]; i++) {
        NSMutableArray * groupOrdered = [distanceGroupsOrdered objectAtIndex:i];
        NSMutableArray * groupOrderedFiltered = [distanceGroupsOrderedFiltered objectAtIndex:i];
        [groupOrderedFiltered removeAllObjects];
        for (OrderedUser * orderedUser in groupOrdered) {
            // filter for company
            if (company) {
                NSLog(@"User %@ company %@ filter %@", orderedUser.userInfo.username, orderedUser.userInfo.company.lowercaseString, company);
                if (!orderedUser.userInfo.company)
                    continue;
                if ([orderedUser.userInfo.company.lowercaseString rangeOfString:company].location == NSNotFound)
                    continue;
                NSLog(@"Passed");
            }

            // filter for industry
            if (industry) {
                NSLog(@"User %@ industry %@ filter %@", orderedUser.userInfo.username, orderedUser.userInfo.industry.lowercaseString, industry);
                if (!orderedUser.userInfo.industry)
                    continue;
                if ([orderedUser.userInfo.industry.lowercaseString rangeOfString:industry].location == NSNotFound)
                    continue;
                NSLog(@"Passed");
            }
            
            // filter for friends in common...skip for now
            
            [groupOrderedFiltered addObject:orderedUser];
        }
        NSLog(@"Distance group %d total users %d filtered users %d", i, [groupOrdered count], [groupOrderedFiltered count]);
    }
    
    [self.tableView reloadData];
}

/*
#pragma mark EGOrefresh

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;

    [self refreshProximity];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    //[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
    refreshHeaderView 
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(PF_EGORefreshTableHeaderView*)view{
    // pull to refresh
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}
 */
#pragma mark UIScrollViewDelegate Callbacks for ego refresh
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    if (scrollView == self.panelScrollView)
    //        return;
    
    if (scrollView.isDragging) {
        if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to normal");
            [refreshHeaderView setState:EGOOPullRefreshNormal];
        } else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
            NSLog(@"ScrollView: EGO refreshHeaderView going to pulling");
            [refreshHeaderView setState:EGOOPullRefreshPulling];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //    if (scrollView == self.panelScrollView)
    //        return;
    
    if (scrollView.contentOffset.y <= - 40.0f && !_reloading) {
        _reloading = YES;
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationCurveLinear
                         animations:^{
                             [self.tableView setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0)];
                         }
                         completion:^(BOOL finished){
                             [self reloadTableViewDataSource];
                         }
         ];
    }
}

#pragma mark -
#pragma mark refreshHeaderView Methods

- (void)dataSourceDidFinishLoadingNewData{
    
    [self.tableView reloadData];
    if (_reloading) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        
        [refreshHeaderView setState:EGOOPullRefreshNormal];
    }
    _reloading = NO;
}

-(void)reloadTableViewDataSource {
    NSLog(@"Pull to refresh");
    _reloading = YES;
    [self refreshProximity];
}



@end
