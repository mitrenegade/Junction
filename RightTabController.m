//
//  RightTabController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "RightTabController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface RightTabController ()

@end

@implementation RightTabController

@synthesize sidebarView, contentView;
//@synthesize headerView;
@synthesize viewControllers, sidebarItems;
@synthesize shareController, chatController, profileController;
@synthesize labelBlock, labelConnect, buttonBlock, buttonConnect;
@synthesize userInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewControllers = [[NSMutableArray alloc] init];
        sidebarItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"<-" style:UIBarButtonItemStylePlain target:self action:@selector(closeRightTab:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
     */
    [self.navigationController setNavigationBarHidden:YES];
    /*
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.alpha = 0.7f;
    [self.navigationController.navigationBar setTranslucent:YES];
     */

    CGRect frame = sidebarView.frame;
    frame.size.width = SIDEBAR_WIDTH;
    [sidebarView setFrame:frame];
    
    [self addDefaultControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsSentUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsReceivedUpdated
                                               object:nil];
    
    [self updateConnections];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addController:(UIViewController*)viewController withNormalImage:(UIImage*)normalImage andHighlightedImage:(UIImage*)highlightedImage andTitle:(NSString*)title {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectSidebarItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTag:[sidebarItems count]];
    int dim = SIDEBAR_WIDTH;
    int FIRST_BUTTON_OFFSET = buttonConnect.frame.size.height;
    button.frame = CGRectMake(0, (dim+20)*button.tag + FIRST_BUTTON_OFFSET, dim, dim+20);
    
    UILabel * buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, dim, dim, 20)];
    [buttonTitle setText:title];
    [buttonTitle setBackgroundColor:[UIColor clearColor]];
    [buttonTitle setFont:[UIFont systemFontOfSize:10]];
    [buttonTitle setTextColor:[UIColor whiteColor]];
    [buttonTitle setTextAlignment:NSTextAlignmentCenter];
    [buttonTitle setAdjustsFontSizeToFitWidth:YES];
    [button addSubview:buttonTitle];
    
    [sidebarItems addObject:button];
    [viewControllers addObject:viewController];
}

-(void)selectSidebarItem:(id)sender {
    UIButton * button = (UIButton*)sender;
    int index = button.tag;
    if (index > [viewControllers count])
        return;
    [self didSelectViewController:index];
}

-(void)didSelectViewController:(int)index {
    UIViewController * controller = [viewControllers objectAtIndex:index];
    //    if ([controller respondsToSelector:@selector(headerView)]) {
    //        UIView * header = controller.headerView;
    //    }
    for (UIView * subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [self.contentView addSubview:[controller view]];
    CGRect frame = self.contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [controller.view setFrame:frame];
    NSLog(@"ContentView: %f %f controller view: %f %f", contentView.frame.size.width, contentView.frame.size.height, controller.view.frame.size.width, controller.view.frame.size.height);
}

-(void)addDefaultControllers {
    self.profileController = [[UserProfileViewController alloc] init];
    [self.profileController setUserInfo:self.userInfo];
    self.chatController = [[UserChatViewController alloc] init];
    [self.chatController setUserInfo:self.userInfo];
    self.shareController = [[UserShareViewController alloc] init];
    [self.shareController setUserInfo:self.userInfo];
    
    [self addController:self.profileController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Profile"];
    [self addController:self.chatController withNormalImage:[UIImage imageNamed:@"speechbubble"] andHighlightedImage:nil andTitle:@"Chat"];
    [self addController:self.shareController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Share"];

    CGRect buttonFrame = CGRectZero;
    for (UIButton * button in sidebarItems) {
        [sidebarView addSubview:button];
        if (button.frame.origin.y > buttonFrame.origin.y)
            buttonFrame = button.frame;
    }

    // shift block button and label down
    buttonFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height;
    buttonBlock = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBlock setImage:[UIImage imageNamed:@"red_x"] forState:UIControlStateNormal];
    [buttonBlock addTarget:self action:@selector(didClickBlock:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBlock setFrame:buttonFrame];
    int dim = SIDEBAR_WIDTH;
    labelBlock = [[UILabel alloc] initWithFrame:CGRectMake(0, dim, dim, 20)];
    [labelBlock setBackgroundColor:[UIColor clearColor]];
    [labelBlock setTextColor:[UIColor whiteColor]];
    [labelBlock setTextAlignment:NSTextAlignmentCenter];
    [labelBlock setFont:[UIFont systemFontOfSize:10]];
    [labelBlock setAdjustsFontSizeToFitWidth:YES];
    [labelBlock setText:@"Block"];
    [buttonBlock addSubview:labelBlock];
    [sidebarView addSubview:buttonBlock];
}

-(void) updateConnections {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
        [self.labelConnect setText:@"Connected"];
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        [self.labelConnect setText:@"Accept"];
    }
    else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
        [self.labelConnect setText:@"Sent"];
    }
    else
        [self.labelConnect setText:@"Connect"];
}

-(IBAction)closeRightTab:(id)sender {
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)didClickConnect:(id)sender {
    NSLog(@"Connect button requested!");
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
        NSLog(@"Already connected!");
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        NSLog(@"Accept connection request!");
        [UIAlertView alertViewWithTitle:@"Accept connection request" message:[NSString stringWithFormat:@"Would you like to accept %@'s connection request?", userInfo.username] cancelButtonTitle:@"Not now" otherButtonTitles:[NSArray arrayWithObjects:@"Accept", @"Reject", nil] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                // accept
                [appDelegate acceptConnectionRequestFromUser:userInfo];
            }
            else if (buttonIndex == 1) {
                // reject
                //[appDelegate rejectConnectionRequestFromUser:sender withNotification:notification];
                NSLog(@"Why? You have few enough friends as it is!");
            }
        } onCancel:^{
            
        }];

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

-(IBAction)didClickBlock:(id)sender {
    NSLog(@"Blocked user!");
}

-(void)dealloc {
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
@end
