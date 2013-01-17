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

@interface UserInfo : ParseUserInfo

@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * password;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * linkedInString;
@property (strong, nonatomic) NSString * headline;
@property (strong, nonatomic) NSString * position;
@property (strong, nonatomic) NSMutableSet * friends;
@property (strong, nonatomic) UIImage * photo;
@property (strong, nonatomic) NSString * photoURL;
@property (strong, nonatomic) NSString * industry;
@property (strong, nonatomic) NSString * summary;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSArray * specialties;
//@property (nonatomic) NSArray * educations;
@property (strong, nonatomic) NSArray * currentPositions;
@property (strong, nonatomic) UserPulse * userPulse;
@property (strong, nonatomic) NSString * pfUserID;

+(void)FindUserInfoFromParse:(UserInfo*)userInfo withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults;
+(void)UpdateUserInfoToParse:(UserInfo*)userInfo;

@end
