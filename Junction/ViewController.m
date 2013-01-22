//
//  ViewController.m
//  Junction
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "ViewController.h"
#import "LinkedInHelper.h"

@implementation ViewController

@synthesize delegate;
@synthesize lhHelper;
@synthesize myUserInfo;
@synthesize activityIndicator;
@synthesize buttonLinkedIn;

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
    [self.navigationController setNavigationBarHidden:YES];
    myUserInfo = [[UserInfo alloc] init]; // create a shell myUserInfo to store any linkedIn that is received
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
#pragma mark LocationViewDelegate functions
- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text = [location description];
    
    CLLocationCoordinate2D zoomLocation;
    //zoomLocation.latitude = 39.281516;
    //zoomLocation.longitude= -76.580806;
    zoomLocation = [location coordinate];
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}

#pragma mark navigationControllerDelegate
-(void)didClickSettings:(id)sender {
    [delegate showUserSettings];
}

-(void)showUserSettings {
    // passed on by MapViewController
    [delegate showUserSettings];
}
*/
-(BOOL)loadCachedOauth {
    // must exist on init so can test cached oauth
    if (!lhHelper) {
        lhHelper  = [[LinkedInHelper alloc] init];
        [lhHelper setDelegate:self];
    }
    return [lhHelper loadCachedOAuth];
}


-(void)tryCachedLogin {
    if (!lhHelper) {
        lhHelper  = [[LinkedInHelper alloc] init];
        [lhHelper setDelegate:self];
    }
    [self.buttonLinkedIn setHidden:YES];
//    [lhHelper profileApiCall];
    [lhHelper getId];
    self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progress.labelText = @"Loading your LinkedIn information";
}

-(IBAction)didClickLinkedIn:(id)sender {
    if (!lhHelper) {
        lhHelper  = [[LinkedInHelper alloc] init];
        [lhHelper setDelegate:self];
    }
//    [self.activityIndicator startAnimating];
    self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progress.labelText = @"Loading your LinkedIn information";
    OAuthLoginView * lhView = [lhHelper loginView];
    [self.view addSubview:lhView.view];
}

#pragma mark LinkedInHelperDelegate
-(void)linkedInDidLoginWithID:(NSString *)userID {
    // if we logged in to linkedIn, we probably need to store the info in myUserInfo
    [myUserInfo setLinkedInString:userID];
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
    
    [self linkedInParseProfileInformation:profile];
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
    id _currentPositions = [profile objectForKey:@"threeCurrentPositions"];
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
        [myUserInfo setUsername:name];
    if (headline)
        [myUserInfo setHeadline:headline];
    if (industry)
        [myUserInfo setIndustry:industry];
    if (summary)
        [myUserInfo setSummary:summary];
    if (email)
        [myUserInfo setEmail:email];
    if (pictureUrl) {
        NSLog(@"PictureURL: %@", pictureUrl);
#if 1
        [self.lhHelper requestOriginalPhotoWithBlock:^(NSString * originalURL) {
            NSLog(@"Picture OriginalURL: %@", originalURL);
            // first save original urls
            //[myUserInfo setPhotoURL:originalURL];
            //[myUserInfo setPhotoBlurURL:originalURL];

            // upload images to AWS and generate new URLs
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:originalURL]]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [myUserInfo savePhotoToAWS:image withBlock:^(BOOL saved) {
                        // force profile to update regular image
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                    } withBlock:^(BOOL saved) {
                        // force profile to update blurred image
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                    }];
                });
            });
        }];
#else
        // upload images to AWS and generate new URLs
        myUserInfo.photoURL = pictureUrl;
        myUserInfo.photoBlurURL = pictureUrl;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [myUserInfo savePhotoToAWS:image withBlock:^(BOOL saved) {
                    // force profile to update regular image
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                } withBlock:^(BOOL saved) {
                    // force profile to update blurred image
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
                }];
            });
        });
#endif
    }
    if (location)
        [myUserInfo setLocation:location];
    if (specialties)
        [myUserInfo setSpecialties:specialties];
    if (currentPositions)
        [myUserInfo setCurrentPositions:currentPositions];
    [delegate saveUserInfoToDefaults];

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
    [self.buttonLinkedIn setHidden:NO];
}

#pragma mark ParseHelper login
-(void)tryLogin {
    NSString * loginID = myUserInfo?myUserInfo.linkedInString:lhHelper.userID;
    self.progress.labelText = @"Logging in...";
    [ParseHelper ParseHelper_loginUsingID:loginID withBlock:^(PFUser * user, NSError * error) {
        if (user) {
            NSLog(@"User LinkedIn %@ exists with PFUser id %@", myUserInfo.linkedInString, [user objectId]);
            /*
            [myUserInfo setPfUser:user];
            [myUserInfo setPfUserID:user.objectId];
             */
            
            // after login with a valid user, always get myUserInfo from parse
            [UserInfo GetUserInfoForPFUser:user withBlock:^(UserInfo * parseUserInfo, NSError * error) {
                if (error) {
                    NSLog(@"GetUserInfo for PFUser received error: %@", error);
                }
                else {
                    if (!parseUserInfo) {
                        // userInfo doesn't exist, must create
                        myUserInfo.pfUser = user;
                        myUserInfo.pfUserID = user.objectId;
                        [[myUserInfo toPFObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                [self.progress hide:YES];
                                [delegate didLoginPFUser:user withUserInfo:myUserInfo];
                            }
                            else {
                                self.progress.labelText = @"Could not save your User info!";
                                [self.progress hide:YES afterDelay:2];
                                [[UIAlertView alertViewWithTitle:@"Error:" message:error.description] show];
                            }
                        }];
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
            NSLog(@"Error: %@ code %d", error.userInfo, errorCode);
            // todo: check whether login failed due to missing user, or wrong user
            if (errorCode == 101) {
                // invalid credentials
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"Current LinkedIn profile for %@ is not registered with Junction! Would you like to sign up?", myUserInfo.username] delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Sign Up", nil] show];
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
    NSString * loginID = myUserInfo?myUserInfo.linkedInString:lhHelper.userID;
    self.progress.labelText = @"Signing up";
    [ParseHelper ParseHelper_signupUsingID:loginID withBlock:^(BOOL bDidSignupUser, NSError * error) {
        if (bDidSignupUser) {
            NSLog(@"User %@ created", lhHelper.userID);
            [self tryLogin];
        }
        else {
            int errorCode = [[error.userInfo objectForKey:@"code"] intValue];
            NSLog(@"Error: %@ code %d", error.userInfo, errorCode);
            if (errorCode == 125) { // invalid email
                self.progress.labelText = @"Signup Failed";
                self.progress.detailsLabelText = @"Please enter a valid email!";
                [self enableLoginButton];
            }
            else {
                self.progress.labelText = @"Signup Failed";
                self.progress.detailsLabelText = [NSString stringWithFormat:@"Could not sign up user %@!", myUserInfo.username];
                [self enableLoginButton];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Button 0 - cancel");
        [self enableLoginButton];
    }
    else if (buttonIndex == 1) {
        NSLog(@"Button 1 - Sign up");
        [self trySignup];
    }
}

-(void)enableLoginButton {
    [self.progress hide:YES afterDelay:3];
    [buttonLinkedIn setHidden:NO];
}

@end
