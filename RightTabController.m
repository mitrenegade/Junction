//
//  RightTabController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "RightTabController.h"
#import "AppDelegate.h"

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
    
    for (UIButton * button in sidebarItems)
        [sidebarView addSubview:button];

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
    int FIRST_BUTTON_OFFSET = buttonBlock.frame.size.height;
    button.frame = CGRectMake(0, (dim+20)*button.tag + FIRST_BUTTON_OFFSET, dim, dim+20);
    
    UILabel * buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, dim, dim, 20)];
    [buttonTitle setText:title];
    [buttonTitle setBackgroundColor:[UIColor clearColor]];
    [buttonTitle setFont:[UIFont systemFontOfSize:10]];
    [buttonTitle setTextColor:[UIColor whiteColor]];
    [buttonTitle setTextAlignment:NSTextAlignmentCenter];
    [button addSubview:buttonTitle];
    
    [sidebarItems addObject:button];
    [viewControllers addObject:viewController];
    
    // shift block button and label down
    CGRect buttonFrame = buttonBlock.frame;
    buttonFrame.origin.y = button.frame.origin.y + button.frame.size.height;
    [buttonBlock setFrame:buttonFrame];
    [labelBlock removeFromSuperview];
    [labelBlock setFrame:CGRectMake(0, dim, dim, 20)];
    [buttonBlock addSubview:labelBlock];
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
