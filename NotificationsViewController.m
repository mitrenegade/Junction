//
//  NotificationsViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "JunctionNotification.h"    
@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

static AppDelegate * appDelegate;

//@synthesize users;
//@synthesize messages;
@synthesize tableView;
@synthesize notifications;
@synthesize connectRequestUserInfos;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar-notifications"]];
        [self.tabBarItem setTitle:@"Notifications"];

        appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // make a custom header label
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIImage * headerbg = [UIImage imageNamed:@"header_bg"];
    [self.navigationController.navigationBar setBackgroundImage:headerbg forBarMetrics:UIBarMetricsDefault];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [titleView setFont:[UIFont boldSystemFontOfSize:23]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:158.0/255.0 blue:205.0/255.0 alpha:1]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    titleView.text = @"Notifications";
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    self.navigationItem.titleView = titleView;
    
#if TESTING
    UIBarButtonItem * leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonFeedback];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    [buttonFeedback.titleLabel setFont:[UIFont fontWithName:@"BreeSerif-Regular" size:12]];
#endif

    self.connectRequestUserInfos = [[NSMutableArray alloc] init];
    self.notifications = [[NSMutableArray alloc] init];
    
    if (refreshHeaderView == nil) {
        
        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
        view.delegate = self;
        [tableView addSubview:view];
        refreshHeaderView = view;
    }
    //  update the last update date
    [refreshHeaderView refreshLastUpdatedDate];
    
    [self refreshNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshNotifications)
                                                 name:kNotificationsChanged
                                               object:nil];
 
}

-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationsChanged
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([notifications count] == 0)
        return 200;
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [notifications count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImageView * photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [photoView setTag:TAG_PHOTO];
        [cell.contentView addSubview:photoView];
        
        UILabel * notificationType = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, self.tableView.frame.size.width-60, 15)];
        [notificationType setFont:[UIFont boldSystemFontOfSize:8]];
        [notificationType setTag:TAG_TEXTLABEL];
        [cell.contentView addSubview:notificationType];

        UILabel * infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, self.tableView.frame.size.width-60, 15)];
        [infoLabel setFont:[UIFont systemFontOfSize:10]];
        [infoLabel setTag:TAG_INFOLABEL];
        [cell.contentView addSubview:infoLabel];

        UILabel * lastRowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.tableView.frame.size.width, 30)];
        [lastRowLabel setFont:[UIFont systemFontOfSize:10]];
        [lastRowLabel setTextAlignment:NSTextAlignmentCenter];
        [lastRowLabel setTag:TAG_LASTROW];
        [cell.contentView addSubview:lastRowLabel];
    }
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    // Configure the cell...
    int row = indexPath.row;
    UIImageView * photoView = (UIImageView*)[cell.contentView viewWithTag:TAG_PHOTO];
    UILabel * notificationType = (UILabel*)[cell.contentView viewWithTag:TAG_TEXTLABEL];
    UILabel * infoLabel = (UILabel*)[cell.contentView viewWithTag:TAG_INFOLABEL];
    UILabel * lastRow = (UILabel*)[cell.contentView viewWithTag:TAG_LASTROW];
    
    if (row >= [notifications count]) {
        [photoView setHidden:YES];
        [notificationType setHidden:YES];
        [infoLabel setHidden:YES];
        [lastRow setHidden:NO];
        [lastRow setText:@"No more notifications"];
        
        if ([notifications count] == 0) {
            [lastRow setText:@"You don't have any new notifications. Notifications will appear when you receive a connection request, a request you sent has been accepted, or when it's time to follow up with a connection."];
        }
        [lastRow setNumberOfLines:0];
        [lastRow sizeToFit];
    }
    else {
        [photoView setHidden:NO];
        [notificationType setHidden:NO];
        [infoLabel setHidden:NO];
        [lastRow setHidden:YES];
        
        JunctionNotification * notification = [notifications objectAtIndex:row];
        NSString * type = notification.type;
        NSString * senderPfUserID = notification.senderPfUserID;
        NSDate * timestamp = notification.pfObject.createdAt;
        UserInfo * sender = [appDelegate getUserInfoWithID:senderPfUserID];
        
        [photoView setImage:sender.photo];
        if ([type isEqualToString:jnConnectionRequestNotification])
            [notificationType setText:@"CONNECTION REQUEST"];
        
        NSString * info = [NSString stringWithFormat:@"%@, %@", sender.username, sender.headline];
        [infoLabel setText:info];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    int row = indexPath.row;
    if (row >= [notifications count]) {
        NSLog(@"No notifications clicked");
        return;
    }
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    JunctionNotification * notification = [notifications objectAtIndex:row];
    NSString * type = notification.type;
    NSString * senderPfUserID = notification.senderPfUserID;
    NSDate * timestamp = notification.pfObject.createdAt;
    UserInfo * sender = [appDelegate getUserInfoWithID:senderPfUserID];
    
    if ([type isEqualToString:jnConnectionRequestNotification]) {
        // todo: need to make sure connections are updated
        //[appDelegate getMyConnectionsReceived];
        // jump to user
        [appDelegate displayUserWithUserInfo:sender forChat:NO];
    }
}

#pragma mark EGOrefresh

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    //[tableView reloadData];
    [self refreshNotifications];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
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
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

-(void)refreshNotifications {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [JunctionNotification FindNotificationsForUser:appDelegate.myUserInfo withBlock:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Error getting notifications! code %d error %@", error.code, error.description);
        }
        else {
            [notifications removeAllObjects];
            NSLog(@"Loaded %d notifications for user %@", [results count], appDelegate.myUserInfo.pfUserID);
            
            for (PFObject * pfObject in results) {
                JunctionNotification * notification = [[JunctionNotification alloc] initWithPFObject:pfObject];
                [notifications addObject:notification];
            }
            [self.tableView reloadData];
        }
    }];
}

-(NSMutableArray*) findNotificationsOfType:(NSString*)notificationType fromSender:(UserInfo*)sender {
    NSMutableArray * returnArray = [[NSMutableArray alloc] init];
    for (JunctionNotification * notif in notifications) {
        if ([notif.type isEqualToString:notificationType] && [notif.senderPfUserID isEqualToString:sender.pfUserID])
//            return notif;
            [returnArray addObject:notif];
    }
    return returnArray;
}

#pragma mark feedback
-(IBAction)didClickFeedback:(id)sender {
    [appDelegate sendFeedback:@"Notifications view"];
}
@end
