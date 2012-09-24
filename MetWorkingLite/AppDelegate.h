//
//  AppDelegate.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "ProximityViewController.h"
#import "ParseHelper.h"

static NSString* const kMyUserInfoDidChangeNotification= @"kMyUserInfoDidChangeNotification";

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LoginViewDelegate, LinkedInHelperDelegate, UITabBarControllerDelegate, ProximityDelegate, ProfileDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic) UserInfo * myUserInfo;
@property (nonatomic) UINavigationController * nav;
@property (nonatomic) UINavigationController * navLogin;
@property (nonatomic) LinkedInHelper * lhHelper;
@property (nonatomic) UIViewController * lhView; // hack

@property (nonatomic) ProximityViewController * proxController;
@property (nonatomic) ProfileViewController * profileController;
@property (nonatomic) MapViewController * mapViewController;
@property (nonatomic) LoginViewController * loginController;
@end
