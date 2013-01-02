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
    [lhHelper profileApiCall];
}

-(IBAction)didClickLinkedIn:(id)sender {
    if (!lhHelper) {
        lhHelper  = [[LinkedInHelper alloc] init];
        [lhHelper setDelegate:self];
    }
    [self.activityIndicator startAnimating];
    OAuthLoginView * lhView = [lhHelper loginView];
    [self.view addSubview:lhView.view];
}

#pragma mark LinkedInHelperDelegate
-(void)linkedInDidLoginWithID:(NSString *)userID {
    [myUserInfo setLinkedInString:userID];
    NSLog(@"LinkedIn ID received: %@", myUserInfo.linkedInString);
    
    // Parse user will be created using LinkedIn string
    [self tryLogin:NO];
    
    // request profile info
    [lhHelper requestAllProfileInfoForID:userID];
    
    // request friends
    [lhHelper requestFriends];
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
        [myUserInfo setPhoto:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]]];
        [myUserInfo setPhotoURL:pictureUrl];
    }
    if (location)
        [myUserInfo setLocation:location];
    if (specialties)
        [myUserInfo setSpecialties:specialties];
    if (currentPositions)
        [myUserInfo setCurrentPositions:currentPositions];
    [delegate saveUserInfo];
    
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
 //       [proxController addUser:userID withName:name withHeadline:headline withPhoto:photo atDistance:dist++];
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
-(void)tryLogin:(BOOL)isNewUser {
    [ParseHelper ParseHelper_loginUsername:myUserInfo.linkedInString withBlock:^(PFUser * user, NSError * error) {
        if (user) {
            NSLog(@"User LinkedIn %@ exists with PFUser id %@", myUserInfo.linkedInString, [user objectId]);
            //[delegate didLoginWithUsername:username andEmail:email andPhoto:[[buttonPhoto imageView] image] andPfUser:user];
            [myUserInfo setPfUser:user];
            [myUserInfo setPfUserID:user.objectId];
            [delegate didLogin:isNewUser];
        }
        else {
            NSLog(@"Error: %@", error.userInfo);
            // todo: check whether login failed due to missing user, or wrong user
            if ([[error.userInfo objectForKey:@"code"] intValue] == 101) {
                // invalid credentials
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"Current LinkedIn profile for %@ is not registered with Junction! Would you like to sign up?", myUserInfo.username] delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Sign Up", nil] show];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"There was an unknown issue with login. Please try again later!"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
        }
    }];
}

-(void)trySignup {
    [ParseHelper ParseHelper_signupUsername:myUserInfo.linkedInString withBlock:^(BOOL bDidSignupUser, NSError * error) {
        if (bDidSignupUser) {
            NSLog(@"User %@ created", myUserInfo.username);
            [self tryLogin:YES];
        }
        else {
            NSLog(@"Error: %@", error.userInfo);
            if ([[error.userInfo objectForKey:@"code"] intValue] == 125) { // invalid email
                [[[UIAlertView alloc] initWithTitle:@"Signup Failed" message:@"Please enter a valid email!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                [self enableLoginButton];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Signup Failed" message:[NSString stringWithFormat:@"Could not sign up user %@!", myUserInfo.username] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
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
    [buttonLinkedIn setHidden:NO];
}

-(UserInfo*)getMyUserInfo {
    return [delegate getMyUserInfo];
}

@end
