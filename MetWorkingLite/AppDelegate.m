//
//  AppDelegate.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;
//@synthesize viewController = _viewController;
@synthesize myUserInfo;
@synthesize nav, navLogin;
@synthesize lhHelper, lhView;
@synthesize proxController, profileController, mapViewController, loginController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //ViewController * viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //[viewController setDelegate:self];
    
    //self.viewController = viewController;
    [Parse setApplicationId:@"DZQGQhktsXFRFj4yXEeePFcdLc5VjuLkvTq9dY4c" clientKey:@"aV2QzGLjAfRSceAcQuoSf3NWRW5ge0VNmMvU1Ws4"];    
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];
    
    UITabBarController * tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
    
    proxController = [[ProximityViewController alloc] init];
    [proxController setDelegate:self];
    
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setDelegate:self];
    //[self.navigationController pushViewController:mapViewController animated:YES];
    
    profileController = [[ProfileViewController alloc] init];
    [profileController setDelegate:self];
    
	NSArray * viewControllers = [NSArray arrayWithObjects: proxController, mapViewController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
    
    //[self.view addSubview:tabBarController.view];
    nav = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // check for cached existing user - first check Parse
    // If we have a cached user, we'll get it back here
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) 
    {
        // A user was cached, so check userdefaults for user information
        myUserInfo = [self loadUserInfo];
        if (!myUserInfo) {
            [self doLogin];
        }
        else {
            // update friends list, etc
            // update profiles
            [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
        }
    } 
    else
    {
        [self doLogin];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)doLogin {
    myUserInfo = [[UserInfo alloc] init];
    
    /*** login view navigation - present another nav controller for the login process as a modal controller ***/
    loginController = [[LoginViewController alloc] init];
    [loginController setDelegate:self];
    [loginController initializeWithUserInfo:myUserInfo];
    
    //[nav pushViewController:loginController animated:NO];
    [nav presentModalViewController:loginController animated:NO];
}

-(void)saveUserInfo {
    // archive most recent tags for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * cacheData = [NSKeyedArchiver archivedDataWithRootObject:myUserInfo];
    [defaults setObject:cacheData forKey:@"myUserInfoData"];
    [defaults synchronize];
}

-(UserInfo*)loadUserInfo {
    
    // load cached tags
    // archive most recent tags for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * cacheData = [defaults objectForKey:@"myUserInfoData"];
    if (!cacheData)
        return nil;
    UserInfo * cachedUserInfo = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
    return cachedUserInfo;
}

#pragma mark LoginViewDelegate

-(void)didSelectUsername:(NSString *)username andEmail:(NSString *)email andPhoto:(UIImage *)photo {
    // login without linkedIn information
    [myUserInfo setUsername:username];
    [myUserInfo setEmail:email];
    [myUserInfo setPhoto:photo];
    
    [self validateUserWithBlock:^(BOOL bDidLoginUser) {
        if (bDidLoginUser) {
            [self saveUserInfo];
            
            //[nav popToRootViewControllerAnimated:YES];
            [nav dismissModalViewControllerAnimated:YES];
            
            // update profiles
            [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
        }
        else {
            NSLog(@"Invalid user!");
        }
    }];
}

-(void)didLoginWithLinkedInString:(NSString *)linkedInID andProfileInformation:(NSDictionary *)profile{
    [myUserInfo setLinkedInString:linkedInID];

    // close login controller and do the rest of linkedIn requests here
    //[nav popToRootViewControllerAnimated:YES];
    [nav dismissModalViewControllerAnimated:YES];
    
    [self linkedInParseProfileInformation:profile];

    [self validateUserWithBlock:^(BOOL bDidLoginUser) {
        if (bDidLoginUser) {
            lhHelper = [[LinkedInHelper alloc] init];
            [lhHelper setDelegate:self];
            lhView = [lhHelper loginView];
            
            // request friends
            [lhHelper requestFriends];
        }
        else {
            NSLog(@"Invalid user!");
        }
    }];
}

-(void)linkedInParseProfileInformation:(NSDictionary*)profile {
    // returns the following information: first-name,last-name,industry,location:(name),specialties,summary,picture-url,email-address,educations,three-current-positions
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
    if (pictureUrl)
        [myUserInfo setPhoto:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]]];
    if (location)
        [myUserInfo setLocation:location];
    if (specialties)
        [myUserInfo setSpecialties:specialties];
    if (currentPositions)
        [myUserInfo setCurrentPositions:currentPositions];
    [self saveUserInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
}

-(void)linkedInParseFriends:(id)friendsResults {
    NSLog(@"Friends: %@", friendsResults);
    NSArray * friends = [friendsResults objectForKey:@"values"];
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
        [proxController addUser:userID withName:name withHeadline:headline withPhoto:photo atDistance:dist++];
    }
}

#pragma mark ProximityDelegate and ProfileDelegate

-(UserInfo*)getMyUserInfo {
    return myUserInfo;
}

#pragma creation/validation of user
-(void)validateUserWithBlock:(void (^)(BOOL bUserIsValid))isValidUser {
    NSLog(@"Validating user %@ with linkedInString %@", myUserInfo.username, myUserInfo.linkedInString);
    
    // todo: use Parse to validate user. If parse user exists and some info match, return YES.
    // if parse user exists and info does not match, return NO.
    // if parse user does not exist, add to parse and return YES.
//    if ([myUserInfo.username length]>0 || [myUserInfo.linkedInString length] > 0) {
    [ParseHelper login:myUserInfo withBlock:^(BOOL bUserExists) {
        if (bUserExists) {
            NSLog(@"User %@ exists", myUserInfo.username);
            isValidUser(YES);
        }
        else {
            [ParseHelper signup:myUserInfo withBlock:^(BOOL bDidSignupUser) {
                if (bDidSignupUser) {
                    NSLog(@"User %@ was added", myUserInfo.username);
                    isValidUser(YES);
                }
                else 
                    NSLog(@"Could not validate user %@!", myUserInfo.username);
                    isValidUser(NO);
            }];
        }        
    }];
}
@end
