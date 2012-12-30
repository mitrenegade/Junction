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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
        UserInfo * sender = [appDelegate getUserInfoForPfUserID:senderPfUserID];
        
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
    UserInfo * sender = [appDelegate getUserInfoForPfUserID:senderPfUserID];
    
    if ([type isEqualToString:jnConnectionRequestNotification]) {
        [UIAlertView alertViewWithTitle:@"Accept connection request" message:[NSString stringWithFormat:@"Would you like to accept %@'s connection request?", sender.username] cancelButtonTitle:@"Not now" otherButtonTitles:[NSArray arrayWithObjects:@"Accept", @"Reject", nil] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
#if 0
                // accept
                [appDelegate acceptConnectionRequestFromUser:sender withNotification:notification];
#else
                // jump to user
                [appDelegate displayUserWithUserInfo:sender];
#endif
            }
            else if (buttonIndex == 1) {
                // reject
                //[appDelegate rejectConnectionRequestFromUser:sender withNotification:notification];
            }
        } onCancel:^{
            
        }];
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
@end
