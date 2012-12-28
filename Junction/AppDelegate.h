//
//  AppDelegate.h
//  Junction
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "ProximityViewController.h"
#import "ParseHelper.h"
#import "LinkedInHelper.h"
#import "SideTabController.h"
#import "ChatsTableViewController.h"
#import "NotificationsViewController.h"
#import "Constants.h"
#import "RightTabController.h"

static NSString* const kMyUserInfoDidChangeNotification= @"kMyUserInfoDidChangeNotification";
static NSString* const kParseFriendsStartedUpdatingNotification = @"kParseFriendsStartedUpdatingNotification";
static NSString* const kParseFriendsFinishedUpdatingNotification = @"kParseFriendsFinishedUpdatingNotification";
static NSString* const kParseConnectionsUpdated = @"kParseConnectionsUpdated";
static NSString* const kParseConnectionsSentUpdated = @"kParseConnectionsSentUpdated";
static NSString* const kParseConnectionsReceivedUpdated = @"kParseConnectionsReceivedUpdated";

// junction notifications
static NSString * const jnConnectionRequestNotification = @"jnConnectionRequestNotification";

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LinkedInHelperDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, strong) UINavigationController * nav;
@property (assign, nonatomic) UINavigationController * navLogin;
@property (nonatomic, weak) LinkedInHelper * lhHelper;
@property (assign, nonatomic) UIViewController * lhView; // hack

@property (nonatomic) UserInfo * myUserInfo;

@property (nonatomic, strong) ProximityViewController * proxController;
@property (nonatomic, strong) ProfileViewController * profileController;
@property (nonatomic, strong) ProximityViewController * connectionsController;
@property (nonatomic, strong) MapViewController * mapViewController;
@property (nonatomic, strong) ChatsTableViewController * chatsTableController;
@property (nonatomic, strong) NotificationsViewController * notificationsController;

@property (nonatomic) CLLocationManager * locationManager;
@property (nonatomic) CLLocation * lastLocation;

@property (nonatomic) NSMutableDictionary * linkedInFriends;
@property (nonatomic) NSMutableArray * allJunctionUserInfos;
@property (nonatomic) NSMutableDictionary * allPulses;

// Parse relations
@property (nonatomic, strong) NSMutableSet * connected;
@property (nonatomic, strong) NSMutableSet * connectRequestsReceived;
@property (nonatomic, strong) NSMutableSet * connectRequestsSent;

-(UserInfo*)getUserInfoForPfUserID:(NSString*)pfUserID;
-(void)displayUserWithUserInfo:(UserInfo*)friendUserInfo;
-(BOOL)isConnectedWithUser:(UserInfo*)user;
-(BOOL)isConnectRequestSentToUser:(UserInfo*)user;
-(BOOL)isConnectRequestReceivedFromUser:(UserInfo*)user;
-(void)sendConnectionRequestToUser:(UserInfo*)user;
@end
