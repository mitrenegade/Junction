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
#import "ChatBrowserViewController.h"
#import "NotificationsViewController.h"
#import "Constants.h"
#import "JunctionNotification.h"
#import "Chat.h"
#import "MBProgressHUD.h"
#import "SettingsViewController.h"
#import "IntroViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

static NSString* const kMyUserInfoDidChangeNotification= @"kMyUserInfoDidChangeNotification";
static NSString* const kParseFriendsStartedUpdatingNotification = @"kParseFriendsStartedUpdatingNotification";
static NSString* const kParseFriendsFinishedUpdatingNotification = @"kParseFriendsFinishedUpdatingNotification";
static NSString* const kParseConnectionsUpdated = @"kParseConnectionsUpdated";
static NSString* const kParseConnectionsSentUpdated = @"kParseConnectionsSentUpdated";
static NSString* const kParseConnectionsReceivedUpdated = @"kParseConnectionsReceivedUpdated";
static NSString* const kNotificationsChanged = @"kNotificationsChanged";
static NSString* const kNeedChatBrowserUpdate = @"kNeedChatBrowserUpdate";
static NSString* const kFilterChanged = @"kFilterChanged";

// junction notifications - stored as objects in Parse
static NSString * const jnConnectionRequestNotification = @"jnConnectionRequestNotification";
static NSString * const jnChatReceived = @"jnChatReceived";
static NSString * const jnChatsSeenUpdated = @"jnChatsSeenUpdated";

// junction push notifications - sent from web as push notifications
static NSString * const jpChatMessage = @"jpChatMessage";
static NSString * const jpConnectionRequest = @"jpConnectionRequest";
static NSString * const jpConnectionAccepted = @"jpConnectionAccepted";

@interface AppDelegate : UIResponder <UIApplicationDelegate, LinkedInHelperDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) IntroViewController * introViewController;
@property (nonatomic, strong) UINavigationController * nav;
@property (assign, nonatomic) UINavigationController * navLogin;
@property (nonatomic, weak) LinkedInHelper * lhHelper;
@property (assign, nonatomic) UIViewController * lhView; // hack

@property (nonatomic) UserInfo * myUserInfo;

@property (nonatomic, strong) ProximityViewController * proxController;
@property (nonatomic, strong) ProfileViewController * profileController;
@property (nonatomic, strong) ProximityViewController * connectionsController;
@property (nonatomic, strong) MapViewController * mapViewController;
@property (nonatomic, strong) ChatBrowserViewController * chatsTableController;
@property (nonatomic, strong) NotificationsViewController * notificationsController;
@property (nonatomic, strong) SettingsViewController * settingsController;
@property (nonatomic) CLLocationManager * locationManager;
@property (nonatomic) CLLocation * lastLocation;

@property (nonatomic) NSMutableDictionary * linkedInFriends;
@property (nonatomic) NSMutableArray * allJunctionUserInfos;
@property (nonatomic) NSMutableDictionary * allJunctionUserInfosDict;
@property (nonatomic) NSMutableDictionary * allPulses;

// Parse relations
@property (nonatomic, strong) NSMutableSet * connected;
@property (nonatomic, strong) NSMutableSet * connectRequestsReceived;
@property (nonatomic, strong) NSMutableSet * connectRequestsSent;

@property (nonatomic) NSData * notificationDeviceToken;

// chats
@property (nonatomic) NSMutableDictionary * allRecentChats;

// notification settings
@property (nonatomic) BOOL bShowNotificationConnectionReceived;
@property (nonatomic) BOOL bShowNotificationConnectionAccepted;
@property (nonatomic) BOOL bShowNotificationFollowup;
@property (nonatomic) int followupReminderTimeInWeeks;

-(void)getJunctionUsers;
-(UserInfo*)getUserInfoWithID:(NSString*)pfUserID;
-(void)displayUserWithUserInfo:(UserInfo*)friendUserInfo forChat:(BOOL)forChat;
-(BOOL)isConnectedWithUser:(UserInfo*)user;
-(BOOL)isConnectRequestSentToUser:(UserInfo*)user;
-(BOOL)isConnectRequestReceivedFromUser:(UserInfo*)user;
-(void)sendConnectionRequestToUser:(UserInfo*)user;
-(void)acceptConnectionRequestFromUser:(UserInfo*)user;
-(void)updateChatBrowserWithChat:(Chat*)mostRecentChatReceived;
-(void)saveUserInfoToParse;
-(void)forcePulse;
-(void)deleteUser;
-(void)logout;

-(void)sendFeedback:(NSString*)message;
-(void)loadPhotoFromWebWithBlock:(void(^)(UIImage*))gotImage;
-(void)loadPhotoBlurFromWebWithBlock:(void(^)(UIImage*))gotImage;
-(UIImage*)blurPhoto:(UIImage*)photo atPrivacyLevel:(int)newPrivacyLevel;
-(BOOL)hasNewChatFromUserInfo:(UserInfo*)userInfo;
-(void)didSeeChat:(Chat*)seenChat fromUserInfo:(UserInfo*)userInfo;

// notification settings
-(void)loadNotificationPreferences;
-(void)saveNotificationPreferences;

@end
