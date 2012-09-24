//
//  LoginViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInfo.h"
#import "LinkedInHelper.h"
#import "UserInfo.h"

@protocol LoginViewDelegate

-(void)didSelectUsername:(NSString*)username andEmail:(NSString*)email andPhoto:(UIImage*)photo;
-(void)didLoginWithLinkedInString:(NSString*)linkedInID andProfileInformation:(NSDictionary*)profile;
-(void)didClickLinkedIn;
-(UserInfo*)getMyUserInfo;
@end

@interface LoginViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, LinkedInHelperDelegate>
{
    NSString * linkedInString;
    UITextField * currentField;
    BOOL keyboardIsShown;
}
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic) IBOutlet UIButton * buttonPhoto;
@property (nonatomic) IBOutlet UITextField * usernameField;
@property (nonatomic) IBOutlet UITextField * emailField;
@property (nonatomic) IBOutlet UIScrollView * scrollView;
@property (nonatomic) LinkedInHelper * lhHelper;
@property (nonatomic) UserInfo * myUserInfo;
@property (nonatomic) IBOutlet UIButton * buttonLinkedIn;
@property (nonatomic) IBOutlet UILabel * labelLinkedIn;

-(IBAction)didClickPhotoButton:(id)sender;
-(void)initializeWithUserInfo:(UserInfo*)myUserInfo;
-(IBAction)didClickLinkedIn:(id)sender;
-(IBAction)didClickGoButton:(id)sender;
@end
