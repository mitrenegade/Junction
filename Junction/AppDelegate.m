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
#import "IntroViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JunctionNotification.h"
#import "Chat.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "UIImage+Resize.h"
#import "UIImage+GaussianBlur.h"
#import "UIImage+StackBlur.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize introViewController;
@synthesize myUserInfo;
@synthesize nav, navLogin;
@synthesize lhHelper, lhView;
@synthesize proxController, profileController, mapViewController;
@synthesize connectionsController;
@synthesize locationManager;
@synthesize lastLocation;
@synthesize linkedInFriends;
@synthesize allJunctionUserInfos,allJunctionUserInfosDict;
@synthesize allPulses;
@synthesize notificationsController;
@synthesize chatsTableController;
@synthesize connected, connectRequestsReceived, connectRequestsSent;
@synthesize notificationDeviceToken;
@synthesize allRecentChats;
@synthesize settingsController;
@synthesize bShowNotificationConnectionAccepted, bShowNotificationConnectionReceived, bShowNotificationFollowup, followupReminderTimeInWeeks;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"DZQGQhktsXFRFj4yXEeePFcdLc5VjuLkvTq9dY4c" clientKey:@"aV2QzGLjAfRSceAcQuoSf3NWRW5ge0VNmMvU1Ws4"];
    [Crashlytics startWithAPIKey:@"747b4305662b69b595ac36f88f9c2abe54885ba3"];
    
    // register for apple notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self locationSetHighAccuracy];

    allPulses = [[NSMutableDictionary alloc] init];
    connected = [[NSMutableSet alloc] init];
    connectRequestsSent = [[NSMutableSet alloc] init];
    connectRequestsReceived = [[NSMutableSet alloc] init];
    allRecentChats = [[NSMutableDictionary alloc] init];

    // initialize root view controller which is also login controller
    self.introViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    [self.introViewController setDelegate:self];
    self.window.rootViewController = self.introViewController;
    [self.window makeKeyAndVisible];
    

    PFUser * currentUser = [PFUser currentUser];
#if 0 && TESTING
    [self didLoginPFUser:currentUser withUserInfo:nil];
#else
    if (currentUser) {
        NSLog(@"Current PFUser exists.");
        MBProgressHUD * progress = [MBProgressHUD showHUDAddedTo:self.introViewController.view animated:YES];
        progress.labelText = @"Welcome back...";
        [progress show:YES];

        // after login with a valid user, always get myUserInfo from parse
        [UserInfo GetUserInfoForPFUser:currentUser withBlock:^(UserInfo * parseUserInfo, NSError * error) {
            if (error) {
                NSLog(@"GetUserInfo for PFUser received error: %@", error);
                progress.labelText = @"Could not login!";
                [progress hide:YES afterDelay:2];
            }
            else {
                if (!parseUserInfo) {
                    // userInfo doesn't exist, must create by doing a cached login
                    [self.introViewController tryCachedLogin];
                }
                else {
                    [self didLoginPFUser:currentUser withUserInfo:parseUserInfo];
                }
                [progress hide:YES];
            }
        }];
    }
    else {
        // check linkedIn first
        if (![self.introViewController loadCachedOauth]) {
            // need to log in to LinkedIn
            // do nothing; show login viewController
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
            [self.introViewController tryCachedLogin];
        }
    }
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [self saveCachedRecentChats];
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
    
    [self saveCachedRecentChats];
}

#pragma mark parse push notifications
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", [error description]);
    }
    self.notificationDeviceToken = nil;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Tell Parse about the device token.
    NSLog(@"Storing parse device token");
    [PFPush storeDeviceToken:newDeviceToken];
    self.notificationDeviceToken = newDeviceToken;
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if TESTING && 0
    [PFPush handlePush:userInfo];
#endif
    
    // debug - display userInfo
    NSLog(@"%@", userInfo);
    
    //NSDictionary * aps = [userInfo objectForKey:@"aps"];
    NSString * type = [userInfo objectForKey:@"type"];
    NSString * message = [userInfo objectForKey:@"message"];
    NSString * senderID = [userInfo objectForKey:@"sender"];
    NSString * username = [userInfo objectForKey:@"username"];
    UserInfo * senderUserInfo = [allJunctionUserInfosDict objectForKey:senderID];
    if (!senderUserInfo) {
        NSLog(@"Could not find userInfo for user with pfUserID %@", senderID);
        // request junction user, for later
        senderUserInfo = [[UserInfo alloc] init];
        senderUserInfo.pfUserID = senderID;
        senderUserInfo.username = username;
        [UserInfo FindUserInfoFromParse:senderUserInfo withBlock:^(UserInfo * foundUserInfo, NSError * error) {
            [allJunctionUserInfos addObject:foundUserInfo];
            [allJunctionUserInfosDict setObject:foundUserInfo forKey:senderID];
        }];
    }
    
    if ([type isEqualToString:jpChatMessage]) {
        NSLog(@"Chat message received: %@ from %@", message, senderUserInfo.username);
        // add to recent chats
        Chat * chat = [[Chat alloc] init];
        chat.message = message;
        chat.sender = senderID;
        chat.hasBeenSeen = NO;
        //chat.userInfo = [allJunctionUserInfosDict objectForKey:senderID];
        [allRecentChats setObject:chat forKey:senderID];
        [self saveCachedRecentChats];

        [[NSNotificationCenter defaultCenter] postNotificationName:jnChatReceived object:self userInfo:userInfo];
    }
    else if ([type isEqualToString:jpConnectionRequest]) {
        NSLog(@"Connection request received from %@", senderUserInfo.username);
        [UIAlertView alertViewWithTitle:@"Connection Request" message:[NSString stringWithFormat:@"Connection request received from %@", senderUserInfo.username]];
        [self getMyConnections];
        [self getMyConnectionsReceived];
        [self getMyConnectionsSent];
    }
    else if ([type isEqualToString:jpConnectionAccepted]) {
        NSLog(@"Connection request accepted by %@", senderUserInfo.username);
        [UIAlertView alertViewWithTitle:@"Connection Accepted" message:[NSString stringWithFormat:@"You are now connected with %@", senderUserInfo.username]];
        [self getMyConnections];
        [self getMyConnectionsReceived];
        [self getMyConnectionsSent];
    }
}

-(void)getJunctionUsers {
    NSLog(@"Get Junction users");
    [ParseHelper queryForAllParseObjectsWithClass:@"UserInfo" withBlock:^(NSArray * results, NSError * error) {
        if (results) {
            NSLog(@"Got %d users on Parse", [results count]);
            if (!allJunctionUserInfos)
                allJunctionUserInfos = [[NSMutableArray alloc] init];
            if (!allJunctionUserInfosDict)
                allJunctionUserInfosDict = [[NSMutableDictionary alloc] init];
            
            [allJunctionUserInfos removeAllObjects];
            for (PFObject * user in results) {
                UserInfo * friendUserInfo = [[UserInfo alloc] initWithPFObject:user];
                if (!friendUserInfo.isVisible)
                    continue;
                NSLog(@"Junction user %@ with id %@", friendUserInfo.username, friendUserInfo.pfUserID);
#if !TESTING
                if ([friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
//                    continue;
                }
#endif
                [allJunctionUserInfosDict setObject:friendUserInfo forKey:friendUserInfo.pfUserID];
                [allJunctionUserInfos addObject:friendUserInfo];
            }
            
            [self updateFriendDistances];
        }
    }];
}

-(void)linkedInParseSimpleProfile:(NSDictionary *)profile {
    NSLog(@"Here");
}

-(void)saveUserInfoToDefaults {
    // archive most recent tags for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * cacheData = [NSKeyedArchiver archivedDataWithRootObject:myUserInfo];
    [defaults setObject:cacheData forKey:@"myUserInfoData"];
    [defaults synchronize];
}

-(UserInfo*)loadUserInfo {
    // not used
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

-(void)saveUserInfoToParse {
    [UserInfo FindUserInfoFromParse:myUserInfo withBlock:^(UserInfo * userInfo, NSError * error) {
        if (error) {
            NSLog(@"saveUserInfoToParse->FindUserInfoFromParse Error: %@", error);
        }
        else {
            if (userInfo == nil) {
                // no userInfo found
                // user not found, create
                PFObject * jpPFObject = [myUserInfo toPFObject];
                [ParseHelper addParseObjectToParse:jpPFObject withBlock:^(BOOL success, NSError * error) {
                    if (success) {
                        NSLog(@"New user added to parse!");
                        [self continueInit];
                    }
                }];
            }
            else {
                myUserInfo.pfObject = userInfo.pfObject;
                myUserInfo.pfUser = userInfo.pfUser;
                [[myUserInfo toPFObject] saveInBackground];
#if TESTING && 0
                for (UserInfo * friendUserInfo in allJunctionUserInfos) {
                    if (![friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
                        //[ParseHelper addConnectionBetweenUser:myUserInfo andUser:friendUserInfo];
                        //[ParseHelper addConnectionBetweenUser:friendUserInfo andUser:myUserInfo];
                        
                        [ParseHelper removeRelation:@"connectionsSent" betweenUser:myUserInfo andUser:friendUserInfo];
                        [ParseHelper removeRelation:@"connectionsReceived" betweenUser:friendUserInfo andUser:myUserInfo];
                        
                        //[ParseHelper addRelation:@"connectionsSent" betweenUser:myUserInfo andUser:friendUserInfo withBlock:nil];
                        //[ParseHelper addRelation:@"connectionsReceived" betweenUser:friendUserInfo andUser:myUserInfo withBlock:nil];
                    }
                }
#endif
            }
        }
    }];
}

-(void)deleteUser {
    /*
    [myUserInfo.pfUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Could not delete pfUser: error: %@", error);
            return;
        }
        else {
     NSLog(@"PFUser deleted!");
     */
            if (myUserInfo.pfObject) {
                [myUserInfo.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Could not delete userinfo: error: %@", error);
                        return;
                    }
                    else {
                        NSLog(@"MyUserInfo deleted!");
                        
                        [self logout];
                    }
                }];
            }
    /*
        }
    }];
     */
}

-(void)logout {
    [self.introViewController.view setAlpha:0];
    [self.introViewController enableLoginButton];
    [self.introViewController setShellUserInfo:[[UserInfo alloc] init]];
    [self.introViewController clearCachedOAuth];
    myUserInfo = nil;
    
    [self.proxController clearAllPortraits];

    [self.window addSubview:self.introViewController.view];
    [UIView animateWithDuration:1.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{
                         [self.window.rootViewController.view setAlpha:0];
                         [self.introViewController.view setAlpha:1];
                     }
                     completion:^(BOOL finished) {
                         [self.window.rootViewController.view removeFromSuperview];
                         self.window.rootViewController = self.introViewController;
                     }];
}

-(void)saveCachedRecentChats {
    // archive most recent chats for faster loading
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * cachedChats = [[NSMutableArray alloc] init];
    if ([allRecentChats count] == 0)
        return;
    for (Chat * chat in [[allRecentChats objectEnumerator] allObjects]) {
        [cachedChats addObject:chat];
    }
    NSData * cacheData = [NSKeyedArchiver archivedDataWithRootObject:cachedChats];
    [defaults setObject:cacheData forKey:@"recentChats"];
    [defaults synchronize];
}

-(void)loadCachedRecentChats {
    [allRecentChats removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData * cacheData = [defaults objectForKey:@"recentChats"];
    if (!cacheData)
        return;
    NSMutableArray * cachedChats = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
    NSLog(@"Loaded %d cached chats with ids:", [cachedChats count]);
    for (Chat * chat in cachedChats) {
        NSLog(@"Chat user: %@ message: %@", chat.sender, chat.message);
        [allRecentChats setObject:chat forKey:chat.sender];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:jnChatReceived object:self userInfo:nil];
}

-(BOOL)hasNewChatFromUserInfo:(UserInfo*)userInfo {
    Chat * chat = [allRecentChats objectForKey:userInfo.pfUserID];
    if (!chat)
        return NO;
    return (chat.hasBeenSeen == NO);
}

-(void)didSeeChat:(Chat*)seenChat fromUserInfo:(UserInfo*)userInfo {
    Chat * chat = [allRecentChats objectForKey:userInfo.pfUserID];
    if ([chat.message isEqualToString:seenChat.message] && chat.hasBeenSeen == NO) {
        // todo: compare timestamps too
        chat.hasBeenSeen = YES;
        [self saveCachedRecentChats];
        
        NSString * senderID = chat.sender;
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:senderID forKey:@"sender"];
        [[NSNotificationCenter defaultCenter] postNotificationName:jnChatsSeenUpdated object:self userInfo:userInfo];
    }
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
-(void)startPulsing {
    NSLog(@"Start pulsing");
    if ([CLLocationManager locationServicesEnabled]) {
        //        [self.locationManager startMonitoringSignificantLocationChanges]; // monitor changes
        NSLog(@"Location services enabled? %d", [CLLocationManager locationServicesEnabled]);
        [self.locationManager startUpdatingLocation];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Location Services Off" message:@"Could not discover your location! Please ensure GPS or wireless are on." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
}

-(void)locationSetHighAccuracy {
    // we are monitoring significant changes, these have no effect
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self performSelector:@selector(locationSetHighAccuracyInBackground) withObject:nil afterDelay:30];
}
-(void)locationSetHighAccuracyInBackground {
    // we are monitoring significant changes, these have no effect
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDistanceFilter:25]; // movement threshold for new events - in meters
}
-(void)locationSetLowAccuracy {
    // we are monitoring significant changes, these have no effect
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager setDistanceFilter:25];
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
            @try {
                [UserPulse DoUserPulseWithLocation:lastLocation forUser:myUserInfo withBlock:^(BOOL success) {
                    if (!success) {
                        [self performSelector:@selector(redoPulseForLastLocation:) withObject:lastLocation afterDelay:30];
                    }
                    else {
                        NSLog(@"Pulsed own location! setting to userInfo");
                        [allPulses setObject:myUserInfo.userPulse forKey:myUserInfo.pfUserID];
                    }
                }];
                // update friends distances - without rerequesting
                NSLog(@"Location changed! Recalculating friend distances");
                [self updateFriendDistances];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception found! %@", exception.description);
                if ([exception.description isEqualToString:@"This object has an outstanding network connection. You have to wait until it's done."])
                    NSLog(@"Be patient! your last pulse was still uploading");
            }
        }
    }
}

-(void)redoPulseForLastLocation:(CLLocation*)lastloc {
    @try {
        [UserPulse DoUserPulseWithLocation:lastloc forUser:myUserInfo withBlock:^(BOOL success) {
            if (!success)
                NSLog(@"Could not pulse your location! We tried twice!");
            else
                [self updateFriendDistances];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception found! %@", exception.description);
        if ([exception.description isEqualToString:@"This object has an outstanding network connection. You have to wait until it's done."])
            NSLog(@"Be patient! your last pulse was still uploading");
    }
}

-(void)forcePulse {
    if (lastLocation) {
        [self redoPulseForLastLocation:lastLocation];
    }
    else {
        [self locationSetHighAccuracy];
        [self startPulsing];
    }
}

#pragma mark ProximityDelegate and ProfileDelegate

-(UserInfo*)getMyUserInfo {
    return myUserInfo;
}

-(UserInfo*)getUserInfoWithID:(NSString*)pfUserID {
    for (UserInfo* userInfo in allJunctionUserInfos) {
        if ([userInfo.pfUserID isEqualToString:pfUserID])
            return userInfo;
    }
    return nil;
}

#pragma mark ViewControllerDelegate - new login process
-(void)didLoginPFUser:(PFUser*)pfUser withUserInfo:(UserInfo*)parseUserInfo {
    myUserInfo = parseUserInfo;
    
    if (myUserInfo.photo == nil) {
        [self loadPhotoFromWebWithBlock:nil];
    }

    NSLog(@"Login successful! Adding tabs!");
    UITabBarController * tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
    
    proxController = [[ProximityViewController alloc] init];
    connectionsController = [[ProximityViewController alloc] init];
    [connectionsController setShowConnectionsOnly:YES];
    [connectionsController.tabBarItem setImage:[UIImage imageNamed:@"tabbar-connections"]];
    [connectionsController.tabBarItem setTitle:@"Connections"];
    notificationsController = [[NotificationsViewController alloc] init];
    chatsTableController = [[ChatBrowserViewController alloc] init];
    settingsController = [[SettingsViewController alloc] init];
    profileController = [[ProfileViewController alloc] init];
    
#if USING_SIDETAB
    SideTabController * tabController = [[SideTabController alloc] init];
    [tabController addController:proxController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Browse"];
    [tabController addController:profileController withNormalImage:[UIImage imageNamed:@"tab_me"] andHighlightedImage:nil andTitle:@"Me"];
    [tabController addController:chatsTableController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Chats"];
    [tabController addController:notificationsController withNormalImage:[UIImage imageNamed:@"tab_me"] andHighlightedImage:nil andTitle:@"Notifix"];
    [tabController addController:connectionsController withNormalImage:[UIImage imageNamed:@"tab_friends"] andHighlightedImage:nil andTitle:@"Connections"];
    [sideTabController didSelectViewController:0];
#else
    UITabBarController * tabController = [[UITabBarController alloc] init];
    UINavigationController * tab0nav = [[UINavigationController alloc] initWithRootViewController:proxController];
    UINavigationController * tab1nav = [[UINavigationController alloc] initWithRootViewController:connectionsController];
    UINavigationController * tab2nav = [[UINavigationController alloc] initWithRootViewController:notificationsController];
    UINavigationController * tab3nav = [[UINavigationController alloc] initWithRootViewController:chatsTableController];
    UINavigationController * tab4nav = [[UINavigationController alloc] initWithRootViewController:settingsController];
    NSArray * viewControllers = [NSArray arrayWithObjects: tab0nav, tab1nav, tab2nav, tab3nav, tab4nav, nil];
    //NSArray * viewControllers = [NSArray arrayWithObjects: proxController, connectionsController, notificationsController, chatsTableController, settingsController, nil];
    [tabBarController setViewControllers:viewControllers];
    [tabBarController setDelegate:self];
    [tabBarController setSelectedIndex:0];
#endif
//    self.nav = [[UINavigationController alloc] initWithRootViewController:tabController];
    
    // this set of animations works correctly. first, dismiss with animation. while animating, the rootView becomes the other one.
    if (self.window.rootViewController == nil) {
        self.window.rootViewController = tabBarController;
        [self.window makeKeyAndVisible];
    }
    else {
        [self.window addSubview:tabBarController.view];
        [tabBarController.view setAlpha:0];
        [UIView animateWithDuration:1.5
                              delay:0.0
                            options:UIViewAnimationOptionTransitionFlipFromRight
                         animations:^{
                             [self.window.rootViewController.view setAlpha:0];
                             [tabBarController.view setAlpha:1];
                         }
                         completion:^(BOOL finished) {
                             [self.window.rootViewController.view removeFromSuperview];
                             self.window.rootViewController = tabBarController;
                         }];
    }
    
    NSLog(@"MyUserInfo pfUser: %@", myUserInfo.pfUser);
    
    [self continueInit];
}

-(void)continueInit {
//    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self loadNotificationPreferences];
    [self loadCachedRecentChats];
    [self getJunctionUsers];
    [self startPulsing];
    [self getMyConnections];
    [self getMyConnectionsReceived];
    [self getMyConnectionsSent];
    
    // register for push
    [ParseHelper Parse_subscribeToChannel:myUserInfo.pfUserID];
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
    NSLog(@"Updating distances for %d users", [allJunctionUserInfos count]);
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
        {
            UserPulse * myPulse = [allPulses objectForKey:myUserInfo.pfUserID];
            if (myPulse) {
                [proxController reloadUserPortrait:myUserInfo withPulse:myPulse];
                continue;
            }
        }
#endif
        // todo: do in background so UI doesn't freeze
        [UserPulse FindUserPulseForUserInfo:friendUserInfo withBlock:^(NSArray * results, NSError * error) {
            if (error || [results count] == 0) {
                NSLog(@"Could not find pulse for user %@", friendUserInfo.username);
            }
            else {
                //                    PFObject * object = [results objectAtIndex:0];
                UserPulse * pulse = [results objectAtIndex:0];//[[UserPulse alloc] initWithPFObject:object];
                //NSLog(@"User %@ %@ found at coord %f %f", friendUserInfo.username, friendUserInfo.pfUserID, pulse.coordinate.latitude, pulse.coordinate.longitude);
                
                [allPulses setObject:pulse forKey:friendUserInfo.pfUserID];
                [proxController reloadUserPortrait:friendUserInfo withPulse:pulse];
                // todo: use that to calculate distance, requires own coordinate from gps
                
                float distanceInMeters = 999;
                if (lastLocation) {
                    CLLocation * friendLocation = [[CLLocation alloc] initWithLatitude:pulse.coordinate.latitude longitude:pulse.coordinate.longitude];
                    distanceInMeters = [lastLocation distanceFromLocation:friendLocation];
                }
            }
        }];
        
    }
}

-(BOOL)isConnectedWithUser:(UserInfo*)user {
    if ([user.pfUserID isEqualToString:myUserInfo.pfUserID])
        return YES;
    /*
    for (NSString * pfUserID in connected) {
        if ([pfUserID isEqualToString:user.pfUserID]) {
            NSLog(@"User %@ with pfUserID %@ is connected!", user.username, user.pfUserID);
            return YES;
        }
    }
     */
    if ([connected containsObject:user.pfUserID])
        return YES;
    return NO;
}

-(void)displayUserWithUserInfo:(UserInfo*)friendUserInfo forChat:(BOOL)forChat {
    if ([friendUserInfo.pfUserID isEqualToString:myUserInfo.pfUserID]) {
        ProfileViewController * controller = [[ProfileViewController alloc] init];
        [controller setMyUserInfo:myUserInfo];
        [self.window.rootViewController presentModalViewController:controller animated:YES];
    }
    else {
        if (forChat) {
            UserChatViewController * chatController = [[UserChatViewController alloc] init];
            [chatController setUserInfo:friendUserInfo];
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:chatController];
            [self.window.rootViewController presentModalViewController:nav animated:YES];
        }
        else {
            UserProfileViewController * controller = [[UserProfileViewController alloc] init];
            [controller setUserInfo:friendUserInfo];
            [self.window.rootViewController presentModalViewController:controller animated:YES];
        }
    }
}

-(void)getMyConnections {
    NSLog(@"GetMyConnections started");
    static int getMyConnectionsRetry = 1;
    [ParseHelper findRelation:@"connections" forUser:myUserInfo withBlock:^(NSArray * connectedUsers, NSError * error) {
        if (error) {
            NSLog(@"getMyConnections->findRelation failed with error: %@", error.description);
            if (getMyConnectionsRetry)
                [self performSelector:@selector(getMyConnections) withObject:nil afterDelay:300];
            getMyConnectionsRetry = 0;
        }
        else {
            NSLog(@"%d connections found for user %@", [connectedUsers count], myUserInfo.username);
            for (PFObject * user in connectedUsers) {
                UserInfo * connectedUserInfo = [[UserInfo alloc] initWithPFObject:user];
                NSLog(@"Connected user: class %@ pfObjectID %@ pfUserID: %@", [user class], ((PFObject*)user).objectId, connectedUserInfo.pfUserID);
                [connected addObject:connectedUserInfo.pfUserID];
                
                // remove from other lists
                [connectRequestsReceived removeObject:connectedUserInfo.pfUserID];
                [connectRequestsSent removeObject:connectedUserInfo.pfUserID];
            }
            NSLog(@"Connected users: %@", connected);
            [[NSNotificationCenter defaultCenter] postNotificationName:kParseConnectionsUpdated object:self userInfo:nil];
        }
    }];
    NSLog(@"GetMyConnections finished");
}

-(void)getMyConnectionsSent {
    NSLog(@"GetMyConnectionsSent started");
    static int getMyConnectionsSentRetry = 1;
    [ParseHelper findRelation:@"connectionsSent" forUser:myUserInfo withBlock:^(NSArray * connectedUsers, NSError * error) {
        if (error) {
            if (getMyConnectionsSentRetry)
                [self performSelector:@selector(getMyConnectionsSent) withObject:nil afterDelay:300];
            getMyConnectionsSentRetry = 0;
        }
        else {
            NSLog(@"%d connection requests sent by user %@", [connectedUsers count], myUserInfo.username);
            for (PFObject * user in connectedUsers) {
                NSLog(@"Connect sent for user: pfObjectID %@", ((PFObject*)user).objectId);
                UserInfo * connectedUserInfo = [[UserInfo alloc] initWithPFObject:user];
                [connectRequestsSent addObject:connectedUserInfo.pfUserID];
                [[NSNotificationCenter defaultCenter] postNotificationName:kParseConnectionsSentUpdated object:self userInfo:nil];
            }
        }
    }];
    NSLog(@"GetMyConnectionsSent started");

}

-(void)getMyConnectionsReceived {
    NSLog(@"GetMyConnectionsReceived started");
    static int getMyConnectionsReceivedRetry = 1;
    [ParseHelper findRelation:@"connectionsReceived" forUser:myUserInfo withBlock:^(NSArray * connectedUsers, NSError * error) {
        if (error) {
            if (getMyConnectionsReceivedRetry)
                [self performSelector:@selector(getMyConnectionsReceived) withObject:nil afterDelay:300];
            getMyConnectionsReceivedRetry = 0;
        }
        else {
            NSLog(@"%d connection requests received by user %@", [connectedUsers count], myUserInfo.username);
            for (PFObject * user in connectedUsers) {
                NSLog(@"Connect sent from user: pfObjectID %@", ((PFObject*)user).objectId);
                UserInfo * connectedUserInfo = [[UserInfo alloc] initWithPFObject:user];
                [connectRequestsReceived addObject:connectedUserInfo.pfUserID];
                [[NSNotificationCenter defaultCenter] postNotificationName:kParseConnectionsReceivedUpdated object:self userInfo:nil];
            }
        }
    }];
    NSLog(@"GetMyConnectionsReceived started");
}

-(BOOL)isConnectRequestSentToUser:(UserInfo*)user {
    /*
    for (UserInfo * userInfo in connectRequestsSent) {
        NSLog(@"Userinfo: %@ user: %@", userInfo.pfUserID, user.pfUserID);
        if ([userInfo.pfUserID isEqualToString:user.pfUserID]) {
            NSLog(@"User with pfUserID %@ is connected!", user.pfUserID);
            return YES;
        }
    }
     */
    if ([connectRequestsSent containsObject:user.pfUserID])
        return YES;
    return NO;
}
-(BOOL)isConnectRequestReceivedFromUser:(UserInfo*)user {
    /*
    for (UserInfo * userInfo in connectRequestsReceived) {
        if ([userInfo.pfUserID isEqualToString:user.pfUserID]) {
            NSLog(@"User with pfUserID %@ is connected!", user.pfUserID);
            return YES;
        }
    }
     */
    if ([connectRequestsReceived containsObject:user.pfUserID])
        return YES;
    return NO;
}

-(void)sendConnectionRequestToUser:(UserInfo *)user {
    [ParseHelper addRelation:@"connectionsSent" betweenUser:myUserInfo andUser:user withBlock:^(BOOL succeeded, NSError * error) {
        if (!succeeded) {
            NSLog(@"Add relation got error: %@", error.description);
        }
        else {
            [self getMyConnectionsSent];
        }
    }];
    [ParseHelper addRelation:@"connectionsReceived" betweenUser:user andUser:myUserInfo withBlock:^(BOOL succeeded, NSError * error) {
        if (!succeeded) {
            NSLog(@"Add relation got error: %@", error.description);
        }
        else {
            // no need to update requests received
        }
    }];
    
    // send notification to user to update requests!
    NSString * channel = [user.pfUserID stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%@ wants to connect", self.myUserInfo.username] forKey:@"alert"];
    [data setObject:self.myUserInfo.pfUserID forKey:@"sender"];
    [data setObject:self.myUserInfo.username forKey:@"username"];
    [data setObject:jpConnectionRequest forKey:@"type"];
    [data setObject:channel forKey:@"channel"];
    [PFPush sendPushDataToChannelInBackground:channel withData:data];
    
    // create notification for display
    JunctionNotification * notification = [[JunctionNotification alloc] init];
    [notification setSenderPfUserID:myUserInfo.pfUserID];
    [notification setPfUserID:user.pfUserID];
    [notification setPfUser:user.pfUser];
    [notification setType:jnConnectionRequestNotification];
    PFObject * pfObject = [notification toPFObject];
    [pfObject saveEventually:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Notification created!");
        }
    }];
}

-(void)acceptConnectionRequestFromUser:(UserInfo*)userInfo {
    MBProgressHUD * progress = [MBProgressHUD showHUDAddedTo:self.window.rootViewController.presentedViewController.view animated:YES]; //self.nav.topViewController.view animated:YES];

    [ParseHelper removeRelation:@"connectionsReceived" betweenUser:myUserInfo andUser:userInfo];
    [ParseHelper removeRelation:@"connectionsReceived" betweenUser:userInfo andUser:myUserInfo];
    [ParseHelper removeRelation:@"connectionsSent" betweenUser:userInfo andUser:myUserInfo];
    [ParseHelper removeRelation:@"connectionsSent" betweenUser:myUserInfo andUser:userInfo];
    [ParseHelper addRelation:@"connections" betweenUser:myUserInfo andUser:userInfo withBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            NSLog(@"AcceptConnectionRequest->addRelation had error: %@", error);
        }
        else {
            NSLog(@"Connection created! success!");
            [self getMyConnectionsReceived];
            [self getMyConnections];
        }
        [progress hide:YES];
    }];
    [ParseHelper addRelation:@"connections" betweenUser:userInfo andUser:myUserInfo withBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            NSLog(@"AcceptConnectionRequest->addRelation had error: %@", error);
        }
        else {
            NSLog(@"Connection created! success!");
            [self getMyConnectionsReceived];
            [self getMyConnections];
        }
        [progress hide:YES];
    }];
    
    // send notification for user to update
    NSString * channel = [userInfo.pfUserID stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSString stringWithFormat:@"%@ accepted your connection", self.myUserInfo.username] forKey:@"alert"];
    [data setObject:self.myUserInfo.pfUserID forKey:@"sender"];
    [data setObject:self.myUserInfo.username forKey:@"username"];
    [data setObject:jpConnectionAccepted forKey:@"type"];
    [data setObject:channel forKey:@"channel"];
    [PFPush sendPushDataToChannelInBackground:channel withData:data];
    
    NSMutableArray * notificationsForDeletion = [self.notificationsController findNotificationsOfType:jnConnectionRequestNotification fromSender:userInfo];
    
    if ([notificationsForDeletion count] == 0) {
        //[notificationsController refreshNotifications];
        return;
    }
    
    // todo: check here if notificationsForDeletion works. handle error (no internet)
    for (JunctionNotification * notificationForDeletion in notificationsForDeletion) {
        [notificationForDeletion.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Could not delete notification with objectID %@", notificationForDeletion.pfObject.objectId);
            }
            else {
                NSLog(@"Deleted junction notification!");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationsChanged object:self userInfo:nil];
            }
        }];
    }
}

-(void)updateChatBrowserWithChat:(Chat *)mostRecentChatReceived {
    NSString * sender = mostRecentChatReceived.sender;
    Chat * oldChat = [self.allRecentChats objectForKey:sender];
    if (!oldChat || !oldChat.pfObject || !oldChat.pfObject.updatedAt ||[[mostRecentChatReceived.pfObject updatedAt] timeIntervalSinceDate: [oldChat.pfObject updatedAt]] > 0) {
        [self.allRecentChats setObject:mostRecentChatReceived forKey:sender];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedChatBrowserUpdate object:self userInfo:nil];
        
        [self saveCachedRecentChats];
    }
}

#pragma mark feedback MessageController and delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //feedbackMsg.text = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
            //feedbackMsg.text = @"Result: Mail saved";
            break;
        case MFMailComposeResultSent:
            //feedbackMsg.text = @"Result: Mail sent";
            break;
        case MFMailComposeResultFailed:
            //feedbackMsg.text = @"Result: Mail sending failed";
            break;
        default:
            //feedbackMsg.text = @"Result: Mail not sent";
            break;
    }
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

-(void)sendFeedback:(NSString *)message {
    NSLog(@"Message: %@", message);
    if ([MFMailComposeViewController canSendMail]){
        NSMutableArray * recipients = [[NSMutableArray alloc] init];
        [recipients addObject:@"bobbysaadmanojabhay@gmail.com"];
        NSString * subject = [NSString stringWithFormat:@"Junction Alpha Feedback - %@", message];
        NSString * body = [NSString stringWithFormat:@"Feedback about: %@", message];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:recipients];
        [picker setSubject:subject];
        [picker setMessageBody:body isHTML:NO];
        
        //[self.navigationController pushViewController:picker animated:YES];
        if (self.window.rootViewController.presentedViewController != nil) {
            [self.window.rootViewController.presentedViewController presentModalViewController:picker animated:YES];
        }
        else {
            [self.window.rootViewController presentModalViewController:picker animated:YES];
        }
    }
}

-(void)loadPhotoFromWebWithBlock:(void (^)(UIImage *))gotImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString * photoURL = myUserInfo.photoURL;
        UIImage * photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        myUserInfo.photo = photo;
        if (gotImage) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                gotImage(photo);
            });
        }
    });
}
-(void)loadPhotoBlurFromWebWithBlock:(void(^)(UIImage*))gotImage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString * photoBlurURL = myUserInfo.photoBlurURL;
        UIImage * photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoBlurURL]]];
        myUserInfo.photoBlur = photo;
        if (gotImage) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                gotImage(photo);
            });
        }
    });
}

-(UIImage*)blur:(UIImage*)photo {
    //return [photo imageWithGaussianBlur];
    return [photo stackBlur:5];
}

-(UIImage*)blurPhoto:(UIImage*)photo atPrivacyLevel:(int)newPrivacyLevel {
    UIImage * newImage;
    switch (newPrivacyLevel) {
        case 0:
            // do nothing!
            newImage = photo;
            break;
        case 1:
            // one blur
            newImage = [self blur:photo];
            break;
        case 2:
            newImage = [photo stackBlur:10];//[self blur:[self resizeImage:photo byScale:.5]];
            break;
        case 3:
            newImage = [photo stackBlur:20];//[self blur:[self blur:[self resizeImage:photo byScale:.25]]];
            break;
        case 4:
            newImage = [photo stackBlur:50]; //[self blur:[self blur:[self resizeImage:photo byScale:.15]]];
            break;
            /*
        case 5:
            newImage = [[[self resizeImage:photo byScale:.25] stackBlur:10] stackBlur:20]; //[self blur:[self blur:[self resizeImage:photo byScale:.05]]];
            break;
             */
            
        default:
            newImage = photo;
            break;
    }
    return newImage;
}

-(UIImage*)resizeImage:(UIImage*)image byScale:(float)scale {
    CGSize frame = image.size;
    CGSize target = frame;
    target.width *= scale;
    target.height *= scale;
    UIImage * newImage = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
    return newImage;
}

-(void)loadNotificationPreferences {
    // set defaults
    bShowNotificationConnectionAccepted = YES;
    bShowNotificationConnectionReceived = YES;
    bShowNotificationFollowup = YES;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"bShowNotificationConnectionReceived"])
        bShowNotificationConnectionReceived = [defaults boolForKey:@"bShowNotificationConnectionReceived"];
    if ([defaults objectForKey:@"bShowNotificationConnectionAccepted"])
        bShowNotificationConnectionAccepted = [defaults boolForKey:@"bShowNotificationConnectionAccepted"];
    if ([defaults objectForKey:@"bShowNotificationFollowup"])
        bShowNotificationFollowup = [defaults boolForKey:@"bShowNotificationFollowup"];
    if ([defaults objectForKey:@"followupReminderTimeInWeeks"])
        followupReminderTimeInWeeks = [defaults integerForKey:@"followupReminderTimeInWeeks"];
}

-(void)saveNotificationPreferences {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:bShowNotificationConnectionReceived forKey:@"bShowNotificationConnectionReceived"];
    [defaults setBool:bShowNotificationConnectionAccepted forKey:@"bShowNotificationConnectionAccepted"];
    [defaults setBool:bShowNotificationFollowup forKey:@"bShowNotificationFollowup"];
    [defaults setInteger:followupReminderTimeInWeeks forKey:@"followupReminderTimeInWeeks"];
    [defaults synchronize];
}
@end
