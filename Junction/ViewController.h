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
#import "MBProgressHUD.h"

#import "CreateProfilePhotoViewController.h"
#import "CreateProfileInfoViewController.h"
#import "CreateProfilePreviewController.h"

@protocol ViewControllerDelegate <NSObject>

-(void)saveUserInfoToDefaults;
-(BOOL)loadUserInfo;
-(void)didLoginPFUser:(PFUser*)pfUser withUserInfo:(UserInfo*)parseUserInfo;
-(void)didGetLinkedInFriends:(NSArray*)friendResults;

@end

@interface ViewController : UIViewController <UIAlertViewDelegate, CreateProfileInfoDelegate, CreateProfilePhotoDelegate, ProfilePreviewDelegate, LinkedInHelperDelegate, OAuthLoginDelegate, UIScrollViewDelegate>
{
//    IBOutlet UILabel *locationLabel;
//    UITabBarController * tabBarController;
    BOOL doSignup;
}

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) LinkedInHelper * lhHelper;
@property (nonatomic, strong) UserInfo * myUserInfo;
//@property (weak, nonatomic) IBOutlet UIButton * buttonTour;
@property (weak, nonatomic) IBOutlet UIButton * buttonLogIn;
@property (weak, nonatomic) IBOutlet UIButton * buttonSignUp;
@property (weak, nonatomic) IBOutlet UIView * buttonView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;
//@property (nonatomic, weak) IBOutlet UILabel * descriptionLabel;
@property (nonatomic, strong) MBProgressHUD * progress;
@property (nonatomic, strong) UINavigationController * nav;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * viewControllers;
@property (nonatomic, weak) IBOutlet UIPageControl * pageControl;
//- (void)signInToCustomService;
-(IBAction)didClickLinkedIn:(id)sender;
-(IBAction)didClickTour:(id)sender;
-(BOOL)loadCachedOauth;
-(void)tryCachedLogin;
-(void)linkedInDidLoginWithID:(NSString *)userID;
-(void)enableLoginButton;
-(void)clearCachedOAuth;
@end
