//
//  ProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h" // for notification constants
#import "UIImage+Resize.h"
#import "Constants.h"

@interface ProfileViewController ()

@end

static AppDelegate * appDelegate;

@implementation ProfileViewController

//@synthesize photoView;
@synthesize myUserInfo;
//@synthesize scrollView;
@synthesize nameLabel;
//@synthesize titleLabel, industryLabel, descriptionFrame;
//@synthesize descriptionView;

@synthesize isViewForConnections;
@synthesize viewForConnections;
@synthesize viewForStrangers;
@synthesize viewForFrame;

@synthesize userProfileViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_me"]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMyUserInfo)
                                                     name:kMyUserInfoDidChangeNotification
                                                   object:nil];
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
    [self setMyUserInfo:[appDelegate myUserInfo]];
    titleView.text = @"Junction";

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
    
    self.userProfileViewController = [[UserProfileViewController alloc] init];
    [self.userProfileViewController setUserInfo:appDelegate.myUserInfo];
    [self.userProfileViewController setDelegate:self];
    //[self.userProfileViewController toggleInteraction:NO];
    
    [self.view insertSubview:self.userProfileViewController.view belowSubview:self.buttonView];
    [self.userProfileViewController.view setFrame:self.viewForFrame.frame];

    // start with connected profile
    // hack: asyncimageview doesnt load the blur correctly so lets start without blur
    [self toggleViewForConnections:viewForConnections];
    [self.viewForStrangers setSelected:NO];
}

-(void)updateMyUserInfo {
    [self.userProfileViewController setUserInfo:myUserInfo];
    [self.userProfileViewController toggleViewForConnection:isViewForConnections];
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
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateMyUserInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)toggleViewForConnections:(id)sender {
    if ((UIButton*)sender == viewForConnections) {
        [viewForConnections setSelected:YES];
        [viewForStrangers setSelected:NO];
        isViewForConnections = YES;
    }
    else if ((UIButton*)sender == viewForStrangers) {
        [viewForConnections setSelected:NO];
        [viewForStrangers setSelected:YES];
        isViewForConnections = NO;
    }
    [self updateMyUserInfo];
}

-(UIImage*)resizeImage:(UIImage*)image byScale:(float)scale {
    CGSize frame = image.size;
    CGSize target = frame;
    target.width *= scale;
    target.height *= scale;
    UIImage * newImage = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
    return newImage;
}

#pragma mark UserProfileDelegate
-(void)didClickClose {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark feedback
-(IBAction)didClickFeedback:(id)sender {
    if ([myUserInfo.pfUserID isEqualToString:appDelegate.myUserInfo.pfUserID])
        [appDelegate sendFeedback:@"My Profile view"];
    else
        [appDelegate sendFeedback:@"Other's Profile view"];
}

@end
