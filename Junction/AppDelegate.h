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

static NSString* const kMyUserInfoDidChangeNotification= @"kMyUserInfoDidChangeNotification";
static NSString* const kParseFriendsStartedUpdatingNotification = @"kParseFriendsStartedUpdatingNotification";
static NSString* const kParseFriendsFinishedUpdatingNotification = @"kParseFriendsFinishedUpdatingNotification";

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LinkedInHelperDelegate, UITabBarControllerDelegate, ProximityDelegate, ProfileDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic) UINavigationController * nav;
@property (assign, nonatomic) UINavigationController * navLogin;
@property (nonatomic) LinkedInHelper * lhHelper;
@property (assign, nonatomic) UIViewController * lhView; // hack

@property (nonatomic) UserInfo * myUserInfo;

@property (nonatomic) ProximityViewController * proxController;
@property (nonatomic) ProfileViewController * profileController;
@property (nonatomic) MapViewController * mapViewController;

@property (nonatomic) CLLocationManager * locationManager;
@property (nonatomic) CLLocation * lastLocation;

@property (nonatomic) NSMutableDictionary * linkedInFriends;
@property (nonatomic) NSMutableArray * allJunctionUserInfos;
@property (nonatomic) NSMutableDictionary * allPulses;

@end
