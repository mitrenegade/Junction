//
//  UserChatViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "UserChatViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+GaussianBlur.h"
#import "Chat.h"

@interface UserChatViewController ()

@end

@implementation UserChatViewController
@synthesize userInfo, nameLabel;
@synthesize labelConnectionRequired, buttonConnect;
@synthesize tableView;
@synthesize chatData;
@synthesize chatInput;
@synthesize buttonChat;
@synthesize chatBar;
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
    
    [self updateUserInfo];
    chatData  = [[NSMutableArray alloc] init];
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.chatChannel = [NSString stringWithFormat:@"%@+%@", userInfo.pfUserID, [appDelegate myUserInfo].pfUserID];

    if (refreshHeaderView == nil) {
        
        PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
        view.delegate = self;
        [tableView addSubview:view];
        refreshHeaderView = view;
    }
    //  update the last update date
    [refreshHeaderView refreshLastUpdatedDate];
    
    self.chatInput.delegate = self;
    self.chatInput.clearButtonMode = UITextFieldViewModeWhileEditing;

    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInfo)
                                                 name:kParseConnectionsUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInfo)
                                                 name:kParseConnectionsSentUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserInfo)
                                                 name:kParseConnectionsReceivedUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedChat:)
                                                 name:jnChatReceived
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadLocalChat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    //keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsReceivedUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsSentUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:jnChatReceived
                                                  object:nil];
}

-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
}

#pragma mark - Chat textfield

-(IBAction) textFieldDoneEditing : (id) sender
{
    NSLog(@"the text content%@",chatInput.text);
    [sender resignFirstResponder];
    [chatInput resignFirstResponder];
}

-(IBAction) backgroundTap:(id) sender
{
    [self.chatInput resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"the text content%@",chatInput.text);
    [textField resignFirstResponder];
    
    if (chatInput.text.length>0) {
        [self sendChat];
    }
    return NO;
}

-(IBAction)didClickSendChat:(id)sender {
    [chatInput resignFirstResponder];
    if (chatInput.text.length > 0)
        [self sendChat];
}

#pragma mark EGOrefresh

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    [self loadLocalChat];
    [tableView reloadData];
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

#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"Rows: %d", [chatData count]);
    return [chatData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        //[photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [photoView setUserInteractionEnabled:NO];
        photoView.tag = TAG_PHOTO;
        
        UITextView * textLabel = [[UITextView alloc] initWithFrame:CGRectMake(60, 10, self.tableView.frame.size.width - 80, 50)];
        [textLabel setUserInteractionEnabled:NO];
        [textLabel setScrollEnabled:NO];
        textLabel.tag = TAG_TEXTLABEL;

        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 100, 20)];
        timeLabel.tag = TAG_TIMELABEL;
        
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:photoView];
        
#if TESTING && 0
        [photoView setBackgroundColor:[UIColor blueColor]];
        [textLabel setBackgroundColor:[UIColor greenColor]];
        [timeLabel setBackgroundColor:[UIColor redColor]];
#endif
    }

    NSUInteger row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    //PFObject * chatObject = (PFObject*)[chatData objectAtIndex:row];
    Chat * chat = [chatData objectAtIndex:row];
    
    if (row < chatData.count){
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

        NSString *chatText = [chat message];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
        size.width = 150;
        //NSLog(@"Constrained textview size: %f %f", size.width, size.height);
        
        UIButton * photoView = (UIButton*)[cell.contentView viewWithTag:TAG_PHOTO];
        if ([[chat sender] isEqualToString:appDelegate.myUserInfo.pfUserID]) {
            [photoView setImage:appDelegate.myUserInfo.photo forState:UIControlStateNormal];
            [photoView setFrame:CGRectMake(self.tableView.frame.size.width - 50, 10, 40, 40)];
        }
        else if ([[chat sender] isEqualToString:userInfo.pfUserID]) {
            [photoView setImage:self.userPhoto forState:UIControlStateNormal];
            [photoView setFrame:CGRectMake(10, 10, 40, 40)];
        }
        else {
            NSLog(@"Invalid sender: %@!", [chat sender]);
        }
        
        UITextView * textLabel = (UITextView*)[cell.contentView viewWithTag:TAG_TEXTLABEL];
        textLabel.frame = CGRectMake(60, 10, size.width+10, size.height + 30);
        textLabel.font = font;
        textLabel.text = chatText;
        [textLabel sizeToFit];
        
        NSDate *theDate = [chat.pfObject createdAt];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        UILabel * timeLabel = (UILabel*)[cell.contentView viewWithTag:TAG_TIMELABEL];
        if ([[chat sender] isEqualToString:appDelegate.myUserInfo.pfUserID]) {
            [timeLabel setFrame:CGRectMake(self.tableView.frame.size.width - 60, 55, 100, 20)];
        }
        else {
            [timeLabel setFrame:CGRectMake(10, 55, 100, 20)];
        }
        NSString *timeString = [formatter stringFromDate:theDate];
        UIFont * timeFont = [UIFont systemFontOfSize:11];
        [timeLabel setFont:timeFont];
        timeLabel.text = timeString;
        [timeLabel sizeToFit];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    
    NSString *chatText = [[chatData objectAtIndex:row] message];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    UITextView * tmp = [[UITextView alloc] initWithFrame:CGRectMake(60, 10, size.width+10, size.height + 30)];
    tmp.font = font;
    tmp.text = chatText;
//    [tmp sizeToFit];
    CGRect frame = tmp.frame;
    
    float height = MAX(frame.origin.y + frame.size.height, 80);
    //NSLog(@"Height for cell %d: %f", row, height);
    return height;
}

#pragma mark - Parse

- (void)loadLocalChat
{
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    PFQuery *query = [PFQuery queryWithClassName:[Chat getClassName]];
    // additional whereKeys are AND
    NSString * channel1 = [NSString stringWithFormat:@"%@+%@", appDelegate.myUserInfo.pfUserID, userInfo.pfUserID];
    NSString * channel2 = [NSString stringWithFormat:@"%@+%@",  userInfo.pfUserID, appDelegate.myUserInfo.pfUserID];
    //NSString * channel1 = [NSString stringWithFormat:@"%@", appDelegate.myUserInfo.pfUserID];
    //NSString * channel2 = [NSString stringWithFormat:@"%@",  userInfo.pfUserID];
    //[query whereKey:@"chatChannel" containsString:channel1];
    //[query whereKey:@"chatChannel" containsString:channel2];
    [query whereKey:@"chatChannel" containedIn:[NSMutableArray arrayWithObjects:channel1, channel2, nil]];
    NSLog(@"Querying for chats with channel %@ or %@", channel1, channel2);
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([chatData count] == 0) {
        __block Chat * mostRecentChatReceived = nil;
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        //NSLog(@"Trying to retrieve from cache");
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d chats.", objects.count);
                [chatData removeAllObjects];
                for (PFObject * obj in objects) {
                    Chat * chat = [[Chat alloc] initWithPFObject:obj];
                    NSLog(@"Chat time %@ channel: %@ sender: %@ message: %@", chat.pfObject.updatedAt, chat.chatChannel, chat.sender, chat.message);
                    [chatData addObject:chat];
                    
                    // update latest chat
                    if ([chat.sender isEqualToString:userInfo.pfUserID]) {
                        if (!mostRecentChatReceived)
                            mostRecentChatReceived = chat;
                        else if ([[chat.pfObject updatedAt] timeIntervalSinceDate:[mostRecentChatReceived.pfObject updatedAt]] > 0)
                            mostRecentChatReceived = chat;
                    }
                }
                
                if (mostRecentChatReceived) {
                    NSLog(@"Most recent chat: %@ at %@", mostRecentChatReceived.message, mostRecentChatReceived.pfObject.updatedAt);
                    [appDelegate updateChatBrowserWithChat:mostRecentChatReceived];
                }
                
                [tableView reloadData];
                if ([chatData count] > 0) {
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatData count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
                }
                else {
                    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                }
            } else {
                // Log details of the failure
                //NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    else {
        __block int totalNumberOfEntries = 0;
        [query orderByAscending:@"createdAt"];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                NSLog(@"There are currently %d entries", number);
                totalNumberOfEntries = number;
                if (totalNumberOfEntries > [chatData count]) {
                    NSLog(@"Retrieving data");
                    int theLimit;
                    if (totalNumberOfEntries-[chatData count]>MAX_ENTRIES_LOADED) {
                        theLimit = MAX_ENTRIES_LOADED;
                    }
                    else {
                        theLimit = totalNumberOfEntries-[chatData count];
                    }
                    query.limit = theLimit; //[NSNumber numberWithInt:theLimit];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            // The find succeeded.
                            NSLog(@"Successfully retrieved %d chats.", objects.count);
                            for (PFObject * obj in objects) {
                                Chat * chat = [[Chat alloc] initWithPFObject:obj];
                                [chatData addObject:chat];
                            }
                            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                            for (int ind = 0; ind < objects.count; ind++) {
                                NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
                                [insertIndexPaths addObject:newPath];
                            }
                            [tableView beginUpdates];
                            [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                            [tableView endUpdates];
                            [tableView reloadData];
                            if ([chatData count] > 0) {
                                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatData count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
                            }
                            else {
                                //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                            }
                        } else {
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
            } else {
                // The request failed, we'll keep the chatData count?
                number = [chatData count];
            }
        }];
    }

}

#pragma other stuff

-(void)sendChat {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    /*
    PFObject * pfObject = [PFObject objectWithClassName:CLASSNAME];
    [pfObject setObject:self.chatChannel forKey:@"chatChannel"];
    [pfObject setObject:appDelegate.myUserInfo.pfUserID forKey:@"sender"];
    [pfObject setObject:self.chatInput.text forKey:@"message"];
    */
    NSString * message = [chatInput.text copy];

    Chat * chat = [[Chat alloc] init];
    [chat setSender:appDelegate.myUserInfo.pfUserID];
    [chat setMessage:message];
    [chat setChatChannel:self.chatChannel];
    
    // updating the table immediately
    chatInput.text = @"";
    [chatData addObject:chat];
    [tableView reloadData];
    if ([chatData count] > 0) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatData count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    }
    else {
        //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }

    /*
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [insertIndexPaths addObject:newPath];
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [tableView endUpdates];
    */
    
    // send to parse and reload
    [[chat toPFObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            chatInput.text = @"";
            //[chatData addObject:pfObject];
            //[tableView reloadData];
            //[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatData count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            // send notification
#if 0
            [ParseHelper Parse_sendBadgedNotification:message OfType:jpChatMessage toChannel:userInfo.pfUserID fromSender:appDelegate.myUserInfo.pfUserID];
#else
            NSString * channel = [userInfo.pfUserID stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"Parse: sending notification to channel <%@> with message: %@", channel, message);
            
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            [data setObject:[NSString stringWithFormat:@"%@: %@", appDelegate.myUserInfo.username, message] forKey:@"alert"];
            [data setObject:appDelegate.myUserInfo.pfUserID forKey:@"sender"];
            [data setObject:jpChatMessage forKey:@"type"];
            [data setObject:message forKey:@"message"];
            [data setObject:channel forKey:@"channel"];
            [PFPush sendPushDataToChannelInBackground:channel withData:data];
            
#endif
        }
        else {
            if (error)
                NSLog(@"Send chat failed! error: %@", error);
        }
    }];
}

-(void)updateUserInfo {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
        [self toggleChat:YES];
        self.userPhoto = userInfo.photo;
        self.nameLabel.text = userInfo.username;
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        [self toggleChat:YES];
        self.userPhoto = userInfo.photo; // imageWithGaussianBlur] imageWithGaussianBlur];
        self.nameLabel.text = userInfo.username;
    }
    else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
        [self toggleChat:YES];
        self.userPhoto = [[userInfo.photo imageWithGaussianBlur] imageWithGaussianBlur];
        self.nameLabel.text = @"Name hidden";
    }
    else {
        [self toggleChat:NO];
        self.userPhoto = [[userInfo.photo imageWithGaussianBlur] imageWithGaussianBlur];
        self.nameLabel.text = @"Name hidden";
    }
}

-(void)toggleChat:(BOOL)enabled {
    if (enabled) {
        [labelConnectionRequired setHidden:YES];
        [buttonConnect setHidden:YES];
        [tableView setHidden:NO];
    }
    else {
        [labelConnectionRequired setHidden:NO];
        [buttonConnect setHidden:NO];
        [tableView setHidden:YES];
    }
}

-(IBAction)didClickConnect:(id)sender {
    NSLog(@"Connect button requested!");
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
        NSLog(@"Already connected!");
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        NSLog(@"Accept connection request!");
    }
    else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
        NSLog(@"Connection request already sent!");
    }
    else {
        [[UIAlertView alertViewWithTitle:@"Send connection request?" message:[NSString stringWithFormat:@"Do you want to send a connection request to %@?", userInfo.username] cancelButtonTitle:@"Not now" otherButtonTitles:[NSArray arrayWithObject:@"Connect"] onDismiss:^(int buttonIndex) {
            NSLog(@"Sending connection request!");
            [appDelegate sendConnectionRequestToUser:userInfo];
        } onCancel:^{
            NSLog(@"No request sent!");
        }] show];
    }
}

-(void)receivedChat:(NSNotification *)notification {
    NSLog(@"%@", notification);
    
    NSDictionary * dict = notification.userInfo;;
    NSString * type = [dict objectForKey:@"type"];
    NSString * message = [dict objectForKey:@"message"];
    NSString * senderID = [dict objectForKey:@"sender"];
    
    if ([senderID isEqualToString:userInfo.pfUserID]) {
        NSLog(@"It is this user's chat!");
        // add temporary object
        PFObject * chat = [[PFObject alloc] initWithClassName:[Chat getClassName]];
        [chat setObject:message forKey:@"message"];
        [chat setObject:senderID forKey:@"sender"];
        [chatData addObject:chat];
        
        [self.tableView reloadData];
        if ([chatData count] > 0) {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatData count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}
@end
