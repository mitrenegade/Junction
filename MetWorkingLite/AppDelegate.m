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
#import "UserPulse.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize myUserInfo;
@synthesize nav, navLogin;
@synthesize lhHelper, lhView;
@synthesize proxController, profileController, mapViewController;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize linkedInFriends;
@synthesize allJunctionUserInfos;
@synthesize allPulses;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    myUserInfo = [[UserInfo alloc] init];
    _viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [_viewController setMyUserInfo:myUserInfo];
    [_viewController setDelegate:self];
    
    //self.viewController = viewController;
    [Parse setApplicationId:@"DZQGQhktsXFRFj4yXEeePFcdLc5VjuLkvTq9dY4c" clientKey:@"aV2QzGLjAfRSceAcQuoSf3NWRW5ge0VNmMvU1Ws4"];    
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];
    
    self.window.rootViewController = _viewController;
    [self.window makeKeyAndVisible];
    
    lhHelper = [[LinkedInHelper alloc] init];
    [lhHelper setDelegate:self];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [self locationSetHighAccuracy];
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startMonitoringSignificantLocationChanges]; // monitor changes
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Location Services Off" message:@"Could not discover your location! Please ensure GPS or wireless are on." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
    
    // get junction users
    [ParseHelper queryForAllParseObjectsWithClass:@"UserInfo" withBlock:^(NSArray * results, NSError * error) {
        if (results) {
            NSLog(@"Got %d users on Parse", [results count]);
            if (!allJunctionUserInfos)
                allJunctionUserInfos = [[NSMutableArray alloc] init];
            
            [allJunctionUserInfos removeAllObjects];
            for (PFObject * user in results) {
                UserInfo * friendUserInfo = [[UserInfo alloc] initWithPFObject:user];
                NSLog(@"Junction user %@ with id %@", friendUserInfo.username, friendUserInfo.pfUserID);
                if (![friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
                    [allJunctionUserInfos addObject:friendUserInfo];
                }
            }
        }
    }];
    
    allPulses = [[NSMutableDictionary alloc] init];
    
    // check linkedIn first
    if (![lhHelper loadCachedOAuth]) {
        // need to log in to LinkedIn
        //[self doLogin];
        // do nothing; show login
    }
    else
    {
        // linkedIn credentials exist; compare with saved info
//        PFUser *currentUser = [PFUser currentUser];
//        if (currentUser) {
            // load current user info
//        }
        NSLog(@"Logged in!");
        [_viewController tryCachedLogin];
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
    [self locationSetLowAccuracy];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self locationSetHighAccuracy];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)linkedInParseSimpleProfile:(NSDictionary *)profile {
    NSLog(@"Here");
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

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.nav pushViewController:[lhHelper loginView] animated:YES];
        [lhHelper setDelegate:self];
    }
}

#pragma mark CLLocationManager delegate
#define LOCATION_RECENT_TIME_INTERVAL 15.0  // threshold for old location updates - if older than this, we discard
#define LOCATION_MIN_DISTANCE_FOR_UPDATE 10.0 // threshold for updating location to Parse. may not be needed if significantChanges is used
-(void)locationSetHighAccuracy {
    // we are monitoring significant changes, these have no effect
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDistanceFilter:25]; // movement threshold for new events - in meters
}
-(void)locationSetLowAccuracy {
    // we are monitoring significant changes, these have no effect
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager setDistanceFilter:kCLDistanceFilterNone]; 
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    if (lastLocation == nil) {
        lastLocation = [location copy];
    }

    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSLog(@"DidUpdateLocation: %f seconds ago", howRecent);
    if (abs(howRecent) < LOCATION_RECENT_TIME_INTERVAL) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        if ([lastLocation distanceFromLocation:location] > LOCATION_MIN_DISTANCE_FOR_UPDATE) {
            // update location
            lastLocation = [location copy];
            
            // create/update a userPulse into the UserPulse table on parse, for the current pfUser
            [UserPulse DoUserPulseWithLocation:lastLocation forUser:myUserInfo];
            
            // update friends distances - without rerequesting
            NSLog(@"Location changed! Recalculating friend distances");
            [self updateFriendDistances];
        }
    }
}

#pragma mark LoginViewDelegate

-(void)linkedInDidLoginWithID:(NSString *)userID {
    // don't know why it comes here
    [_viewController linkedInDidLoginWithID:userID];
}
-(void)didLoginWithUsername:(NSString *)username andEmail:(NSString *)email andPhoto:(UIImage *)photo andPfUser:(PFUser *)user {
    NSLog(@"Did login with username %@ and PFUser id %@", username, [user objectId]);
    [myUserInfo setUsername:username];
    [myUserInfo setEmail:email];
    [myUserInfo setPhoto:photo];
    [myUserInfo setPfUser:user];
    [myUserInfo setPfUserID:user.objectId];

    [self saveUserInfo];
    
    //[nav popToRootViewControllerAnimated:YES];
    [nav dismissModalViewControllerAnimated:YES];
    
    // update profiles
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
    
    // try linkedIn
    if ([lhHelper isLoggedIn]) {
        [lhHelper requestFriends];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"You're not LinkedIn!" message:@"You haven't added your LinkedIn account. Without your LinkedIn, you can't find friends and network! Would you like to add one?" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Add LinkedIn", nil] show];
    }

}

#pragma mark ProximityDelegate and ProfileDelegate

-(UserInfo*)getMyUserInfo {
    return myUserInfo;
}

#pragma mark ViewControllerDelegate - new login process
-(void)didLogin:(BOOL)isNewUser {
    NSLog(@"Login successful! Adding tabs!");
    UITabBarController * tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
    
    proxController = [[ProximityViewController alloc] init];
    [proxController setDelegate:self];
    
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setDelegate:self];
    
    profileController = [[ProfileViewController alloc] init];
    [profileController setDelegate:self];
    
	NSArray * viewControllers = [NSArray arrayWithObjects: proxController, mapViewController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
    
    nav = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [tabBarController.navigationItem setTitle:@"Junction"];
   
    //[_viewController presentModalViewController:tabBarController animated:YES];
//    [self.viewController presentModalViewController:nav animated:YES];
    [_viewController presentModalViewController:nav animated:YES];
    
    if (isNewUser) {
        // add userinfo for user
        PFObject * jpPFObject = [myUserInfo toPFObject];
        [ParseHelper addParseObjectToParse:jpPFObject withBlock:^(BOOL success, NSError * error) {
            if (success) {
                NSLog(@"addParseObjectToParse: New user added to parse!");
            }
            else {
                NSLog(@"addParseObjectToParse: Could not add new user to Parse!");
            }
        }];
    }
    else {
        [UserInfo UpdateUserInfoToParse:myUserInfo];
        // update userinfo for user
        /*
        PFObject * jpPFObject = [myUserInfo toPFObject];
        [ParseHelper updateParseObject:jpPFObject forUser:myUserInfo.pfUser withBlock:^(BOOL success, NSError * error) {
            if (success) {
                NSLog(@"Existing user information updated in parse!");
            }
            else {
                NSLog(@"Could not update! error: %@", error.description);
            }
        }];
         
        */
    }
}

-(void)didGetLinkedInFriends:(NSArray*)friendResults {
    if (!linkedInFriends) {
        linkedInFriends = [[NSMutableDictionary alloc] init];
    }
    [linkedInFriends removeAllObjects];
    for (NSMutableDictionary * f in friendResults) {
        NSString * friendID = [f objectForKey:@"id"];
        [linkedInFriends setObject:f forKey:friendID];
    }
    
    if (allJunctionUserInfos) {
        [self updateFriendDistances];
    }
}

-(void)updateFriendDistances {
    NSLog(@"Compare junction users with friends!");
    if ([allJunctionUserInfos count] == 0)
        return;
    if ([linkedInFriends count] == 0)
        return;
    
    NSLog(@"junction users: %d", [allJunctionUserInfos count]);
    for (UserInfo * friendUserInfo in allJunctionUserInfos) {
        NSLog(@"Junction user %@ with id %@", friendUserInfo.username, friendUserInfo.pfUserID);
        if (!myUserInfo) {
            NSLog(@"MyUserInfo doesn't exist! Bug");
        }
        else if (!myUserInfo.pfUserID) {
            NSLog(@"myUserInfo doesn't have a userID");
            if ([myUserInfo.linkedInString isEqualToString:friendUserInfo.linkedInString]) {
                // fill in the rest of the info
                [myUserInfo setPfUserID:friendUserInfo.pfUserID];
                [myUserInfo setPfUser:friendUserInfo.pfUser];
            }
        }
        
        if (![friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
            [UserPulse FindUserPulseForUserInfo:friendUserInfo withBlock:^(NSArray * results, NSError * error) {
                NSLog(@"Results for %@: %d", friendUserInfo.username, [results count]);
                if (error) {
                    NSLog(@"Could not find pulse for user %@: error %@", friendUserInfo.username, error.description);
                }
                else {
                    UserPulse * pulse = [results objectAtIndex:0];
                    [allPulses setObject:pulse forKey:friendUserInfo.pfUserID];
                    [proxController reloadAll];
                }
            }];
        }
    }
    
    [mapViewController reloadAll];
}
@end
