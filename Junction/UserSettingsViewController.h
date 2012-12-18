//
//  UserSettingsViewController.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInfo.h"
#import "LinkedInHelper.h"
/*
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "GTMOAuthSignIn.h"
*/
#import "LinkedInHelper.h"

@protocol UserSettingsDelegate

-(void)didSetUsername:(NSString*)username andEmail:(NSString*)email andPhoto:(UIImage*)photo;
    
@end

@interface UserSettingsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
{
    UITextField * currentField;
    BOOL keyboardIsShown;
}
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic) IBOutlet UIButton * buttonPhoto;
@property (nonatomic) IBOutlet UITextField * usernameField;
@property (nonatomic) IBOutlet UITextField * emailField;
@property (nonatomic) IBOutlet UIScrollView * scrollView;

-(IBAction)didClickPhotoButton:(id)sender;
-(void)initializeWithUserInfo:(UserInfo*)myUserInfo;
-(IBAction)didClickLinkedIn:(id)sender;
@end
