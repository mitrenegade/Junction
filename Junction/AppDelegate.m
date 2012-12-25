//
//  AppDelegate.m
//  Junction
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
@synthesize connectionsController;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize linkedInFriends;
@synthesize allJunctionUserInfos;
@synthesize allPulses;
@synthesize notificationsController;
@synthesize chatsTableController;
@synthesize connected;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    myUserInfo = [[UserInfo alloc] init];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.viewController setMyUserInfo:myUserInfo];
    [self.viewController setDelegate:self];
    
    //self.viewController = viewController;
    [Parse setApplicationId:@"DZQGQhktsXFRFj4yXEeePFcdLc5VjuLkvTq9dY4c" clientKey:@"aV2QzGLjAfRSceAcQuoSf3NWRW5ge0VNmMvU1Ws4"];
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //    lhHelper = [[LinkedInHelper alloc] init];
    //    [lhHelper setDelegate:self];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self locationSetHighAccuracy];
    if ([CLLocationManager locationServicesEnabled]) {
//        [self.locationManager startMonitoringSignificantLocationChanges]; // monitor changes
        [self.locationManager startUpdatingLocation];
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
#if !TESTING
                if ([friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
                    continue;
                }
#endif
                [allJunctionUserInfos addObject:friendUserInfo];
            }
            
            [self updateFriendDistances];
        }
    }];
    allPulses = [[NSMutableDictionary alloc] init];
    connected = [[NSMutableSet alloc] init];
    
    // check linkedIn first
    if (![self.viewController loadCachedOauth]) {
        // need to log in to LinkedIn
        //[self doLogin];
        // do nothing; show login
        NSLog(@"No cached oauth");
    }
    else
    {
        // linkedIn credentials exist; compare with saved info
        //        PFUser *currentUser = [PFUser currentUser];
        //        if (currentUser) {
        // load current user info
        //        }
        NSLog(@"Logged in with cached oauth!");
        [self.viewController tryCachedLogin];
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
    [UserInfo FindUserInfoFromParse:cachedUserInfo withBlock:^(UserInfo * userInfo, NSError * error) {
        cachedUserInfo.pfObject = userInfo.pfObject;
        cachedUserInfo.pfUser = userInfo.pfUser;
    }];
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
    NSLog(@"DidUpdateLocation");
    
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSDate* now = [NSDate date];
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < LOCATION_RECENT_TIME_INTERVAL) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
//        if (lastLocation == nil) {
//            lastLocation = [location copy];
//        }
        if (!lastLocation || [lastLocation distanceFromLocation:location] > LOCATION_MIN_DISTANCE_FOR_UPDATE) {
            // update location
            lastLocation = [location copy];
            
            // create/update a userPulse into the UserPulse table on parse, for the current pfUser
            [UserPulse DoUserPulseWithLocation:lastLocation forUser:myUserInfo withBlock:^(BOOL success) {
                if (!success) {
                    [self performSelector:@selector(redoPulseForLastLocation:) withObject:lastLocation afterDelay:30];
                }
            }];
            
            // update friends distances - without rerequesting
            NSLog(@"Location changed! Recalculating friend distances");
            [self updateFriendDistances];
        }
    }
}

-(void)redoPulseForLastLocation:(CLLocation*)lastLocation {
    [UserPulse DoUserPulseWithLocation:lastLocation forUser:myUserInfo withBlock:^(BOOL success) {
        if (!success)
            NSLog(@"Could not pulse your location! We tried twice!");
        else
            [self updateFriendDistances];
    }];
}

#pragma mark LoginViewDelegate
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
    
    //mapViewController = [[MapViewController alloc] init];
    //[mapViewController setDelegate:self];
    
    profileController = [[ProfileViewController alloc] init];
    
    connectionsController = [[ProximityViewController alloc] init];
    [connectionsController setShowConnectionsOnly:YES];

    chatsTableController = [[ChatsTableViewController alloc] init];

    notificationsController = [[NotificationsViewController alloc] init];
    
#if 0
	NSArray * viewControllers = [NSArray arrayWithObjects: proxController, mapViewController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
    nav = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [tabBarController.navigationItem setTitle:@"Junction"];
    [self.viewController presentModalViewController:nav animated:YES];
#else
    SideTabController * sideTabController = [[SideTabController alloc] init];
    [sideTabController addController:proxController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Browse"];
    [sideTabController addController:profileController withNormalImage:[UIImage imageNamed:@"tab_me"] andHighlightedImage:nil andTitle:@"Me"];
    //[sideTabController addController:mapViewController withNormalImage:[UIImage imageNamed:@"tab_world"] andHighlightedImage:nil andTitle:@"Map"];
    [sideTabController addController:chatsTableController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Chats"];
    [sideTabController addController:notificationsController withNormalImage:[UIImage imageNamed:@"tab_me"] andHighlightedImage:nil andTitle:@"Notifix"];
    [sideTabController addController:connectionsController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Connections"];
    
//    [self.viewController presentModalViewController:sideTabController animated:YES];
    
    //UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:sideTabController];
    //[self.viewController presentModalViewController:nav animated:YES];
    
    [self.nav pushViewController:sideTabController animated:YES];
    
    [sideTabController didSelectViewController:0];
#endif
    
    if (isNewUser) {
        // add userinfo for user
        PFObject * jpPFObject = [myUserInfo toPFObject];
        [ParseHelper addParseObjectToParse:jpPFObject withBlock:^(BOOL success, NSError * error) {
            if (success) {
                NSLog(@"New user added to parse!");
            }
        }];
        
    }
    else {
        [UserInfo FindUserInfoFromParse:myUserInfo withBlock:^(UserInfo * userInfo, NSError * error) {
            myUserInfo.pfObject = userInfo.pfObject;
            myUserInfo.pfUser = userInfo.pfUser;

#if TESTING
            for (UserInfo * friendUserInfo in allJunctionUserInfos) {
                if (![friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
                    [ParseHelper addConnectionBetweenUser:myUserInfo andUser:friendUserInfo];
                    [ParseHelper addConnectionBetweenUser:friendUserInfo andUser:myUserInfo];
                }
            }
#endif
            [self getMyConnections];
        }];

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
}

-(void)updateFriendDistances {
    NSLog(@"Compare junction users with friends!");
    if ([allJunctionUserInfos count] == 0)
        return;
    //if ([linkedInFriends count] == 0)
    //    return;
    
    NSArray * allkeys = [[linkedInFriends keyEnumerator] allObjects];
    for (id key in allkeys) {
        NSLog(@"Key: %@ object: %@", key, [linkedInFriends objectForKey:key]);
    }
    
    for (UserInfo * friendUserInfo in allJunctionUserInfos) {
//        UserInfo * friendUserInfo = [[UserInfo alloc] initWithPFObject:user];
        NSLog(@"Comparing junction user %@ with %d LinkedIn friends", friendUserInfo.username, [linkedInFriends count]);
#if !TESTING
        if ([friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID])
            continue;
#endif
        [UserPulse FindUserPulseForUserInfo:friendUserInfo withBlock:^(NSArray * results, NSError * error) {
            if (error || [results count] == 0) {
                NSLog(@"Could not find pulse for user %@", friendUserInfo.username);
            }
            else {
                //                    PFObject * object = [results objectAtIndex:0];
                UserPulse * pulse = [results objectAtIndex:0];//[[UserPulse alloc] initWithPFObject:object];
                NSLog(@"User %@ %@ found at coord %f %f", friendUserInfo.username, friendUserInfo.pfUserID, pulse.coordinate.latitude, pulse.coordinate.longitude);
                
                [allPulses setObject:pulse forKey:friendUserInfo.pfUserID];
                [proxController reloadAll];
                // todo: use that to calculate distance, requires own coordinate from gps
                
                float distanceInMeters = 999;
                if (lastLocation) {
                    CLLocation * friendLocation = [[CLLocation alloc] initWithLatitude:pulse.coordinate.latitude longitude:pulse.coordinate.longitude];
                    distanceInMeters = [lastLocation distanceFromLocation:friendLocation];
                }
                
                /*
                 // populate friends with full information, and strangers with only some information
                 if ([linkedInFriends objectForKey:friendUserInfo.linkedInString] != nil) {
                 NSString * friendID = friendUserInfo.linkedInString;
                 NSMutableDictionary * friend = [linkedInFriends objectForKey:friendID];
                 NSString * friendName = [NSString stringWithFormat:@"%@ %@", [friend objectForKey:@"firstName"], [friend objectForKey:@"lastName"]];
                 NSString * friendHeadline = [friend objectForKey:@"headline"];
                 UIImage * photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[friend objectForKey:@"pictureURL"]]]];
                 NSLog(@"Friend found! name %@ id %@ headline %@",friendName, friendID, friendHeadline);
                 [proxController addUser:friendID withName:friendName withHeadline:friendHeadline withPhoto:photo atDistance:distanceInMeters];
                 }
                 */
            }
        }];
        
    }
}

-(void)getMyConnections {
    [ParseHelper findConnectionsForUser:myUserInfo withBlock:^(NSArray * connectedUsers, NSError * error) {
        NSLog(@"%d connections found for user %@", [connectedUsers count], myUserInfo.username);
        for (PFObject * user in connectedUsers) {
            NSLog(@"Connected user: class %@ pfObjectID %@", [user class], ((PFObject*)user).objectId);
            UserInfo * connectedUserInfo = [[UserInfo alloc] initWithPFObject:user];
            [connected addObject:connectedUserInfo];
        }
        NSLog(@"Connected users: %@", connected);
        [connectionsController reloadAll];
    }];
}

-(BOOL)isConnectedWithUser:(UserInfo*)user {
    for (UserInfo * userInfo in connected) {
        if ([userInfo.linkedInString isEqualToString:user.linkedInString]) {
            NSLog(@"User with linkedInString %@ is connected!", user.linkedInString);
            return YES;
        }
    }
    return NO;
}

-(void)displayUserWithUserInfo:(UserInfo*)friendUserInfo {
    RightTabController * rightTabController = [[RightTabController alloc] init];
    [self.nav pushViewController:rightTabController animated:YES];
    
    [rightTabController didSelectViewController:0];
}
@end
