//
//  UserProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "UserProfileViewController.h"
#import "AppDelegate.h" 

static AppDelegate * appDelegate;

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize photoView;
@synthesize userInfo;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionFrame;
@synthesize delegate;
@synthesize chatController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // must set userinfo before controller is displayed
    [self updateUserInfo];

#if TESTING
    [buttonFeedback setHidden:NO];
    [buttonFeedback.titleLabel setFont:[UIFont fontWithName:@"BreeSerif-Regular" size:12]];
#endif

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
}

-(void)updateUserInfo {
    NSLog(@"UserProfile UpdateUserInfo");
    
    [self.buttonIgnore setHidden:YES];
    CGRect frame = self.buttonConnect.frame;
    frame.origin.x = 5;
    frame.size.width = 310;
    [self.buttonConnect setFrame:frame];
    if ([userInfo.pfUserID isEqualToString:appDelegate.myUserInfo.pfUserID]) {
        // own profile
        isOwnProfile = YES;
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
        
#if TESTING
        [self.buttonConnect setTitle:@"Log out" forState:UIControlStateNormal];
#endif
    }
    else if ([appDelegate isConnectedWithUser:userInfo]) {
        // connected profile
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
        [self.buttonConnect setTitle:@"Connected" forState:UIControlStateNormal];
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        // request received - like connected profile
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
        [self.buttonIgnore setHidden:NO];
        CGRect frame = self.buttonConnect.frame;
        int originalX = frame.origin.x;
        frame.origin.x = self.buttonIgnore.frame.origin.x + self.buttonIgnore.frame.size.width + 5;
        frame.size.width -= (frame.origin.x - originalX);
        [self.buttonConnect setTitle:@"Accept Connection" forState:UIControlStateNormal];
        [self.buttonConnect setFrame:frame];
    }
    else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
        // request sent
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoBlurURL]]];
        if (userInfo.photoBlur)
            [photoView setImage:userInfo.photoBlur];
        [nameLabel setText:ANON_NAME];
        [self.buttonConnect setTitle:@"Connection Requested" forState:UIControlStateNormal];
    }
    else {
        // not connected
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoBlurURL]]];
        if (userInfo.photoBlur)
            [photoView setImage:userInfo.photoBlur];
        [nameLabel setText:ANON_NAME];
        [self.buttonConnect setTitle:@"Connect" forState:UIControlStateNormal];
    }
    NSString * jobTitle = [NSString stringWithFormat:@"%@ @ %@", userInfo.position, userInfo.company];
    [self.titleLabel setText:jobTitle];
    NSString * industryTitle = [[NSString stringWithFormat:@"in %@ industry", userInfo.industry] uppercaseString];
    [self.industryLabel setText:industryTitle];
    
    [self.lookingForDetail setText:userInfo.lookingFor];
    CGSize labelSize = [self.lookingForDetail.text sizeWithFont:self.lookingForDetail.font
                                constrainedToSize:self.lookingForDetail.frame.size
                                    lineBreakMode:UILineBreakModeWordWrap];
    CGRect newframe = self.lookingForDetail.frame;
    newframe.size.width = labelSize.width;
    newframe.size.height = labelSize.height;
    [self.lookingForDetail setFrame:newframe];
    
    CGRect labelFrame = self.talkAboutTitle.frame;
    labelFrame.origin.y = newframe.origin.y + newframe.size.height + 20;
    [self.talkAboutTitle setFrame:labelFrame];
    
    [self.talkAboutDetail setText:userInfo.talkAbout];
    CGRect detailFrame = self.talkAboutDetail.frame;
    detailFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + 20;
    CGSize labelSize2 = [self.talkAboutDetail.text sizeWithFont:self.talkAboutDetail.font
                                              constrainedToSize:self.talkAboutDetail.frame.size
                                                  lineBreakMode:UILineBreakModeWordWrap];
    detailFrame.size.width = labelSize2.width;
    detailFrame.size.height = labelSize2.height;
    [self.talkAboutDetail setFrame:detailFrame];
    
    float width = self.scrollView.frame.size.width;
    float height = self.descriptionFrame.frame.origin.y + self.talkAboutDetail.frame.origin.y + self.talkAboutDetail.frame.size.height + 20;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollView setContentOffset:CGPointMake(0,0)];
    NSLog(@"UserProfile UpdateUserInfo done");
//    NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
}

-(void)toggleViewForConnection:(BOOL)isConnected {
    // used for preview - use only the photos stored in myUserInfo, no AWS link
    [photoView setImageURL:nil];
    if (isConnected) {
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
    }
    else {
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoBlurURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoBlurURL]);
        if (userInfo.photoBlur) {
            [photoView setImage:userInfo.photoBlur];
        }
        [nameLabel setText:ANON_NAME];
    }
}

-(void)toggleInteraction:(BOOL)canInteract {
    if (!canInteract) {
        [self.buttonBlock setEnabled:NO];
        [self.buttonChat setEnabled:NO];
        [self.buttonConnect setEnabled:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsReceivedUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsSentUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsUpdated
                                                  object:nil];
}
-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsReceivedUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsSentUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsUpdated
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserInfo];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)didClickBack:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didClickClose)])
        [delegate didClickClose];
    else
        [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)didClickBlock:(id)sender {
    [[UIAlertView alertViewWithTitle:@"Blocked!" message:@"Why are you blocking me!?"] show];
}

-(IBAction)didClickChat:(id)sender {
//    [[UIAlertView alertViewWithTitle:@"Chat!" message:@"Blah blah blah. Go talk to a real person."] show];
    self.chatController = [[UserChatViewController alloc] init];
    [self.chatController setUserInfo:self.userInfo];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:self.chatController];
    [self presentModalViewController:nav animated:YES];
}

-(IBAction)didClickConnect:(id)sender {
    if (isOwnProfile) {
#if TESTING
        // this becomse a delete button
        [UIAlertView alertViewWithTitle:@"Delete user?" message:@"Are you sure you want to delete your self? You will lose all your Junction info!" cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"Log out", @"Delete", nil] onDismiss:^(int buttonIndex) {
            NSLog(@"Clicked button index %d", buttonIndex);
            // delete user
            if (buttonIndex == 0)
                [appDelegate logout];
            else if (buttonIndex == 1)
                [appDelegate deleteUser];
        } onCancel:^{
            // no deletion
        }];
#endif
    }
    else {
        NSLog(@"Connect button requested!");
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([appDelegate isConnectedWithUser:userInfo]) {
            NSLog(@"Already connected!");
        }
        else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
            NSLog(@"Accepting connection request!");
            [appDelegate acceptConnectionRequestFromUser:userInfo];
        }
        else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
            NSLog(@"Connection request already sent!");
        }
        else {
            [[UIAlertView alertViewWithTitle:@"Send connection request?" message:@"Do you want to send a connection request?" cancelButtonTitle:@"Not now" otherButtonTitles:[NSArray arrayWithObject:@"Connect"] onDismiss:^(int buttonIndex) {
                NSLog(@"Sending connection request!");
                [appDelegate sendConnectionRequestToUser:userInfo];
            } onCancel:^{
                NSLog(@"No request sent!");
            }] show];
        }
    }
}

-(IBAction)didClickIgnore:(id)sender {
    NSLog(@"Ignoring connection request");
    [UIAlertView alertViewWithTitle:@"Request ignored!" message:@"Why even click here? You're not really ignoring them if you click..."];
}

#pragma mark feedback
-(IBAction)didClickFeedback:(id)sender {
    if ([userInfo.pfUserID isEqualToString:appDelegate.myUserInfo.pfUserID])
        [appDelegate sendFeedback:@"My Profile view"];
    else
        [appDelegate sendFeedback:@"Other's Profile view"];
}


@end
