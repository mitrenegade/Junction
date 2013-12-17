//
//  IntroViewController.m
//  Junction
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "IntroViewController.h"
#import "LinkedInHelper.h"
#import "Constants.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "CreateProfileInfoViewController.h"
#import "AppDelegate.h"

@implementation IntroViewController

@synthesize delegate;
@synthesize lhHelper;
@synthesize shellUserInfo;
@synthesize activityIndicator;
@synthesize buttonLogIn, buttonSignUp;
@synthesize buttonView;
@synthesize nav;
@synthesize scrollView, viewControllers;
@synthesize pageControl;

-(id)init {
    self = [super init];
    if (self) {
//        [self.navigationItem setTitle:@"Main"];
        /*
        UIButton * settingsButton = [[UIButton alloc] init];
        [settingsButton setImage:[UIImage imageNamed:@"19-gear"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(didClickSettings:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
        [self.navigationItem setRightBarButtonItem:rightButton];
         */
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    shellUserInfo = [[UserInfo alloc] init]; // create a shell myUserInfo to store any linkedIn that is received
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img-wall.jpg"]];
    
    if (!self.lhHelper) {
        self.lhHelper  = [[LinkedInHelper alloc] init];
        [self.lhHelper setDelegate:self];
    }
    //[self.descriptionLabel setFont:[UIFont fontWithName:@"Bree Serif" size:12]];
    
    [self initializeScroll];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(BOOL)loadCachedOauth {
    // must exist on init so can test cached oauth
    return [lhHelper loadCachedOAuth];
}

-(void)clearCachedOAuth {
    [lhHelper clearCachedOAuth];
}


-(void)tryCachedLogin {
    if (!self.lhHelper) {
        self.lhHelper  = [[LinkedInHelper alloc] init];
        [self.lhHelper setDelegate:self];
    }
    [self hideLoginButton];
    [lhHelper getId];
    
    self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progress.labelText = @"Loading your LinkedIn information";
}

-(IBAction)didClickLinkedIn:(id)sender {
    if (!self.lhHelper) {
        self.lhHelper  = [[LinkedInHelper alloc] init];
        [self.lhHelper setDelegate:self];
    }
    
    UIButton * button = (UIButton*)sender;
    if (1) { //button == buttonLogIn) {
        doSignup = NO;
        if ([self loadCachedOauth]) {
            [self tryCachedLogin];
        }
        else {
            NSLog(@"No cached oauth! Just present login view");
            OAuthLoginView * lhView = [lhHelper loginView];
            [lhView setDelegate:self];
            [self presentModalViewController:lhView animated:YES];
        }
    }
    else if (button == buttonSignUp) {
        /*
        doSignup = YES;
        self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.progress.labelText = @"Loading your LinkedIn information";
        OAuthLoginView * lhView = [lhHelper loginView];
        [lhView setDelegate:self];
        [self presentModalViewController:lhView animated:YES];
         */
    }
}

-(IBAction)didClickTour:(id)sender {
    NSLog(@"Tour!");
    [[UIAlertView alertViewWithTitle:@"Tour!" message:@"Tour tour tour..."] show];
}

#pragma mark LinkedInHelperDelegate
-(void)linkedInDidLoginWithID:(NSString *)userID {
    // if we logged in to linkedIn, we probably need to store the info in shellUserInfo
    [shellUserInfo setLinkedInString:userID];
    NSLog(@"LinkedIn ID received: %@", userID);
    
    // request profile info
    [lhHelper requestAllProfileInfoForID:userID];
    [lhHelper closeLoginView];
    
    // request friends
    //[lhHelper requestFriends];
}

-(void)linkedInParseSimpleProfile:(NSDictionary*)profile {
    // dismiss linkedIn screen, display initial profile info on login screen
    [lhHelper closeLoginView];
    
//    [self linkedInParseProfileInformation:profile];
    NSLog(@"Simple profile: %@", profile);
    NSString * email = [profile objectForKey:@"emailAddress"];
    if (email) {
        NSLog(@"Found email: %@", email);
        [shellUserInfo setEmail:email];
    }
}

-(void)linkedInParseProfileInformation:(NSDictionary*)profile {
    // returns the following information: first-name,last-name,industry,location:(name),specialties,summary,picture-url,email-address,educations,three-current-positions
    //NSString * userID = [profile objectForKey:@"pfUserID"];
    NSString * name = [[NSString alloc] initWithFormat:@"%@ %@",
                       [profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]];
    NSString * headline = [profile objectForKey:@"headline"];
    NSString * industry = [profile objectForKey:@"industry"];
    NSString * summary = [profile objectForKey:@"summary"];
    NSString * pictureUrl = [profile objectForKey:@"pictureUrl"];
    NSString * email = [profile objectForKey:@"emailAddress"];
    NSString * location = [[profile objectForKey:@"location"] objectForKey:@"name"]; // format: "location": {"name": loc}
    id _specialties = [profile objectForKey:@"specialties"];
    //id _educations = [profile objectForKey:@"educations"];
    id _currentPositions = [profile objectForKey:@"positions"];
    NSArray * specialties = nil;
    //NSArray * educations = nil;
    NSArray * currentPositions = nil;
    if (_specialties && [_specialties isKindOfClass:[NSDictionary class]])
        specialties = [_specialties objectForKey:@"values"];
    //if (_educations && [_educations isKindOfClass:[NSDictionary class]])
    //    educations = [_educations objectForKey:@"values"];
    if (_currentPositions && [_currentPositions isKindOfClass:[NSDictionary class]])
        currentPositions = [_currentPositions objectForKey:@"values"];
    
    if (name)
        [shellUserInfo setUsername:name];
    if (headline)
        [shellUserInfo setHeadline:headline];
    if (industry)
        [shellUserInfo setIndustry:industry];
    if (summary)
        [shellUserInfo setSummary:summary];
    if (email)
        [shellUserInfo setEmail:email];
    if (pictureUrl) {
        NSLog(@"PictureURL: %@", pictureUrl);
        // if creating a new user and will go through profile process, must request photo
        [self requestOriginalLinkedInPhoto];
        // if logging in, request this photo but must get AWS photo later
    }
    if (location)
        [shellUserInfo setLocation:location];
    if (specialties)
        [shellUserInfo setSpecialties:specialties];
    if (currentPositions) {
        [shellUserInfo setCurrentPositions:currentPositions];
        id mostRecentPosition = [currentPositions objectAtIndex:0];
        id company = [mostRecentPosition objectForKey:@"company"];
        if ([company objectForKey:@"name"])
            [shellUserInfo setCompany:[company objectForKey:@"name"]];
        if ([company objectForKey:@"industry"]) // select current company's industry over personal industry
            [shellUserInfo setIndustry:[company objectForKey:@"industry"]];
        if ([mostRecentPosition objectForKey:@"title"])
            [shellUserInfo setPosition:[mostRecentPosition objectForKey:@"title"]];
    }
    [delegate saveUserInfoToDefaults];

    if (doSignup) {
        [shellUserInfo setIsVisible:YES]; // visible by default
        [delegate saveUserInfoToDefaults];
        [self trySignup];
    }
    else
        [self tryLogin];    

    // force profile to update
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
}

-(void)linkedInParseFriends:(id)friendsResults {
    NSLog(@"Friends: %@", friendsResults);
    NSArray * friends = [friendsResults objectForKey:@"values"];
#if 0
    int dist = 0;
    for (NSDictionary * d in friends) {
        //NSLog(@"Processing friend %d of total %d", dist, [friends count]);
        NSString * fname = [d objectForKey:@"firstName"];
        NSString * lname = [d objectForKey:@"lastName"];
        NSString * name = [NSString stringWithFormat:@"%@ %@", fname, lname];
        NSString * headline = [d objectForKey:@"headline"];
        NSString * pictureUrl = [d objectForKey:@"pictureUrl"];
        NSString * userID = [d objectForKey:@"id"];
        UIImage * photo = nil;
        if (pictureUrl) {
            photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
        }
    }
#else
    [delegate didGetLinkedInFriends:friends];
#endif
}

-(void)linkedInCredentialsNeedRefresh {
    // received 401 error, manually open linkedIn
    //[self didClickLinkedIn:nil];
    [self enableLoginButton];
}

-(void)linkedInDidFail:(NSError *)error {
    if (error.code == -1001) {
        // timeout
        NSLog(@"Request timed out!");
        self.progress.labelText = @"Could not connect to LinkedIn!";
        self.progress.detailsLabelText = @"Please try again later!";
    }
    else if (error.code == -1009) {
        // no internet
        NSLog(@"No internet connectivity!");
        self.progress.labelText = @"Could not connect to the Internet!";
        self.progress.detailsLabelText = @"Please make sure you are online!";
    }
    [self enableLoginButton];
}

#pragma mark ParseHelper login
-(void)tryLogin {
    NSString * loginID = shellUserInfo?shellUserInfo.linkedInString:lhHelper.userID;
    if (!self.progress)
        self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progress.labelText = @"Logging in...";
    [ParseHelper ParseHelper_loginUsingID:loginID withBlock:^(PFUser * user, NSError * error) {
        if (user) {
            NSLog(@"User LinkedIn %@ exists with PFUser id %@", shellUserInfo.linkedInString, [user objectId]);
            
            // after login with a valid user, always get myUserInfo from parse
            [UserInfo GetUserInfoForPFUser:user withBlock:^(UserInfo * parseUserInfo, NSError * error) {
                if (error) {
                    NSLog(@"GetUserInfo for PFUser received error: %@", error);
                }
                else {
                    if (!parseUserInfo) {
                        // userInfo doesn't exist, must create
                        
                        self.progress.labelText = @"Please create a profile!";
                        
                        shellUserInfo.pfUser = user;
                        shellUserInfo.pfUserID = user.objectId;

                        [self createNewUserProfileWithUser:user];
                    }
                    else {
                        [self.progress hide:YES];
                        [delegate didLoginPFUser:user withUserInfo:parseUserInfo];
                    }
                }
            }];
        }
        else {
            int errorCode = [[error.userInfo objectForKey:@"code"] intValue];
            NSLog(@"Try login Error: %@ code %d", error.userInfo, errorCode);
            // todo: check whether login failed due to missing user, or wrong user
            if (errorCode == 101) {
                // invalid credentials
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"Current LinkedIn profile for %@ is not registered with Junction! Would you like to sign up?", shellUserInfo.username] delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Sign Up", nil] show];
            }
            else if (errorCode == 100) {
                // invalid credentials
                self.progress.labelText = @"Could not connect to our server!";
                self.progress.detailsLabelText = @"Please try again later!";
                [self enableLoginButton];
            }
            else {
                self.progress.labelText = @"Login Failed";
                self.progress.detailsLabelText = @"There was an unknown issue with login. Please try again later!";
                [self enableLoginButton];
            }
        }
    }];
}

-(void)trySignup {
    NSString * loginID = shellUserInfo?shellUserInfo.linkedInString:lhHelper.userID;
    self.progress.labelText = @"Signing up";
    [ParseHelper ParseHelper_signupUsingID:loginID withBlock:^(BOOL bDidSignupUser, NSError * error) {
        if (bDidSignupUser) {
            NSLog(@"User %@ created", lhHelper.userID);
            [self tryLogin];
        }
        else {
            int errorCode = [[error.userInfo objectForKey:@"code"] intValue];
            NSLog(@"Try signup Error: %@ code %d", error.userInfo, errorCode);
            if (errorCode == 125) { // invalid email
                self.progress.labelText = @"Signup Failed";
                self.progress.detailsLabelText = @"Please enter a valid email!";
                [self enableLoginButton];
            }
            else if (errorCode == 202) { // already exists
                self.progress.labelText = @"Signup Failed";
                self.progress.detailsLabelText = [NSString stringWithFormat:@"A user with that LinkedIn account already exists! Try logging in."];
                
                [self enableLoginButton];
            }
            else {
                self.progress.labelText = @"Signup Failed";
                self.progress.detailsLabelText = [NSString stringWithFormat:@"Could not sign up user %@!", shellUserInfo.username];
                
                [self enableLoginButton];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Button 0 - cancel");
        [self.progress hide:YES];
        [self enableLoginButton];
    }
    else if (buttonIndex == 1) {
        NSLog(@"Button 1 - Sign up");
        [self trySignup];
    }
}

-(void)enableLoginButton {
    [self.progress hide:YES afterDelay:3];
    /*
    [self.buttonTour setHidden:NO];
    [self.buttonLogIn setHidden:NO];
    [self.buttonSignUp setHidden:NO];
     */
//    [self.buttonView setHidden:NO];
    [self.buttonLogIn setEnabled:YES];
}
-(void)hideLoginButton {
    /*
    [self.buttonTour setHidden:YES];
    [self.buttonLogIn setHidden:YES];
    [self.buttonSignUp setHidden:YES];
     */
//    [self.buttonView setHidden:YES];
    [self.buttonLogIn setEnabled:NO];
}

-(void)requestOriginalLinkedInPhoto {
    // load photo in background
    [self.lhHelper requestOriginalPhotoWithBlock:^(NSString * originalURL) {
        NSLog(@"Picture OriginalURL: %@", originalURL);
        shellUserInfo.photo = nil;
        shellUserInfo.photoBlur = nil;
        
        // upload unblurred photo to aws
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:originalURL]]];
            // resize
            CGSize frame = image.size;
            float scale = 1;
            if (frame.width < frame.height)
                scale = PROFILE_WIDTH / frame.width;
            else
                scale = PROFILE_HEIGHT / frame.height;
            CGSize target = frame;
            target.width *= scale;
            target.height *= scale;
            image = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
            dispatch_sync(dispatch_get_main_queue(), ^{
                // if we are creating a profile, first save this photo as unblurred
                shellUserInfo.photo = image;
#if 0
                AppDelegate * appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
                [myUserInfo savePhotoToAWS:image withBlock:^(BOOL saved) {
                    // force profile to update regular image
                    appDelegate.myUserInfo.photo = myUserInfo.photo;
                    appDelegate.myUserInfo.photoURL = myUserInfo.photoURL;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                } andBlur:nil withBlock:^(BOOL saved) {
                    // force profile to update blurred image
                    appDelegate.myUserInfo.photoBlur = myUserInfo.photoBlur;
                    appDelegate.myUserInfo.photoBlurURL = myUserInfo.photoBlurURL;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                }];
#endif
            });
        });
    }];
}

#pragma mark creating a new profile for a new user

-(void)createNewUserProfileWithUser:(PFUser*)newUser {
    CreateProfileInfoViewController * controller = [[CreateProfileInfoViewController alloc] init];
    [controller setDelegate:self];
    self.nav = [[UINavigationController alloc] initWithRootViewController:controller];
    self.nav.navigationBar.tintColor = [UIColor colorWithRed:23.0/255 green:153.0/255 blue:228.0/255 alpha:1];
    self.nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self presentModalViewController:self.nav animated:YES];
    
    [controller populateWithUserInfo:shellUserInfo]; // myUserInfo is new shell userInfo
    
    // request original photo here
    //[self requestOriginalLinkedInPhoto];
}

#pragma mark CreateProfileInfoDelegate
-(void)didSaveProfileInfo {
    CreateProfilePhotoViewController * controller = [[CreateProfilePhotoViewController alloc] init];
    [controller setDelegate:self];
    [self.nav pushViewController:controller animated:YES];
    [controller populateWithUserInfo:shellUserInfo];
}

#pragma mark CreateProfilePhotoDelegate
-(void)didSaveProfilePhoto {
    CreateProfilePreviewController * controller = [[CreateProfilePreviewController alloc] init];
    [controller setUserInfo:shellUserInfo];
    [controller setDelegate:self];
    [self.nav pushViewController:controller animated:YES];
}

-(void)didFinishPreview {
    [self dismissModalViewControllerAnimated:YES];
    self.progress.labelText = @"Success!";
    
    // save profile after a delay so dismissModalViewController animation can complete
    [self performSelector:@selector(continueLogin) withObject:nil afterDelay:.5];
}

-(void)continueLogin {
    // save finally created user
    [[shellUserInfo toPFObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.progress hide:YES];
            [delegate didLoginPFUser:shellUserInfo.pfUser withUserInfo:shellUserInfo];
        }
        else {
            self.progress.labelText = @"Could not save your User info!";
            [self.progress hide:YES afterDelay:2];
#if TESTING && 0
            [[UIAlertView alertViewWithTitle:@"Error:" message:error.description] show];
#endif
        }
    }];
}

#pragma mark OAuthLoginDelegate
-(void)didClickBack {
    [self dismissModalViewControllerAnimated:YES];
    [self.progress hide:YES];
}

#pragma mark scrollView
-(void)initializeScroll {
    self.viewControllers = [[NSMutableArray alloc] init];
    NSMutableArray * nibNames = [[NSMutableArray alloc] initWithObjects:@"Tutorial0", @"Tutorial1", @"Tutorial2", @"Tutorial3", @"Tutorial4",  nil];
    for (NSString * nibName in nibNames){
        UIViewController *controller = [[UIViewController alloc] initWithNibName:nibName bundle:nil];
        [controller.view setBackgroundColor:[UIColor clearColor]];
        [self.viewControllers addObject:controller];
    }
    
    int numberOfPages = [self.viewControllers count];
    // a page is the width of the scroll view
    
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = 0;

    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.directionalLockEnabled = YES;
    scrollView.delegate = self;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.viewControllers count])
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [self.viewControllers objectAtIndex:page];
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

#pragma mark ScrollViewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageSize;
    int page;
    pageSize = scrollView.frame.size.width;
    page = floor((scrollView.contentOffset.x - pageSize / 2) / pageSize) + 1;
    if (self.pageControl) {
        [self.pageControl setCurrentPage:page];
    }
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}

@end
