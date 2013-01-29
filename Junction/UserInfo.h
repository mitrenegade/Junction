//
//  UserInfo.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseUserInfo.h"

@class UserPulse;

@interface UserInfo : ParseUserInfo {
//    NSString * photoURL;
//    NSString * photoBlurURL;
}

@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * password;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * linkedInString;
@property (strong, nonatomic) NSString * headline;
@property (strong, nonatomic) NSString * position;
@property (strong, nonatomic) NSString * company;
@property (strong, nonatomic) NSMutableSet * friends;

@property (strong, nonatomic) UIImage * photo;
@property (strong, nonatomic) NSString * photoURL;
@property (strong, nonatomic) UIImage * photoBlur;
@property (strong, nonatomic) NSString * photoBlurURL;

@property (strong, nonatomic) NSString * industry;
@property (strong, nonatomic) NSString * summary;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSArray * specialties;
//@property (nonatomic) NSArray * educations;
@property (strong, nonatomic) NSArray * currentPositions;
@property (strong, nonatomic) UserPulse * userPulse;
@property (strong, nonatomic) NSString * pfUserID;

@property (nonatomic) int privacyLevel; // 0 to 5

+(void)FindUserInfoFromParse:(UserInfo*)userInfo withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults;
+(void)UpdateUserInfoToParse:(UserInfo*)userInfo;

// new login
+(void)GetUserInfoForPFUser:(PFUser*)pfUser withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults;

-(void)savePhotoToAWS:(UIImage*)newPhoto withBlock:(void (^)(BOOL))photoSaved andBlur:(UIImage*)blurPhoto withBlock:(void (^)(BOOL))blurSaved;

@end
