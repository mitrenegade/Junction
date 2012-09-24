//
//  ParseHelper.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 9/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParseHelper.h"
#import <Parse/Parse.h>
#import "UserInfo.h"
//#import "LinkedInHelper.h"

@implementation ParseHelper

//@synthesize delegate;

+ (void)signup:(UserInfo*)userInfo withBlock:(void (^)(BOOL bDidSignupUser))didSignup {
    PFUser *user = [PFUser user];
    user.username = userInfo.username;
    user.password = @"test"; //userInfo.password;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) 
     {
         if (error) // Something went wrong
         { 
             didSignup(NO);
         }
         else {
             // Success!
             didSignup(YES);
         }
     }];
}

+ (void)login:(UserInfo*) userInfo withBlock:(void (^)(BOOL bDidLoginUser))didLogin {
    NSString * username = userInfo.username;
    NSString * password = @"test";
    [PFUser logInWithUsernameInBackground:username 
                                 password:password 
                                    block:^(PFUser *user, NSError *error) 
     {
         if (user) // Login successful
         {
             // Create next view controller to show
             didLogin(YES);
         } 
         else // Login failed
         {
             didLogin(NO);
        }
     }];
}
@end
