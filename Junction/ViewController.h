//
//  ViewController.h
//  Junction
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LinkedInHelper.h"
#import "UserInfo.h"
#import "AppDelegate.h"
#import "ParseHelper.h"

@protocol ViewControllerDelegate <NSObject>

-(void)saveUserInfo;
-(BOOL)loadUserInfo;
-(void)didLogin:(BOOL)isNewUser;
-(void)didGetLinkedInFriends:(NSArray*)friendResults;
-(UserInfo*)getMyUserInfo;

@end

@interface ViewController : UIViewController <UIAlertViewDelegate> //<MapViewDelegate, LocationViewDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate>
{
//    IBOutlet UILabel *locationLabel;
//    UITabBarController * tabBarController;
}

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) LinkedInHelper * lhHelper;
@property (nonatomic, strong) UserInfo * myUserInfo;
@property (weak, nonatomic) IBOutlet UIButton * buttonLinkedIn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;

//- (void)signInToCustomService;
-(IBAction)didClickLinkedIn:(id)sender;
-(BOOL)loadCachedOauth;
-(void)tryCachedLogin;
@end
