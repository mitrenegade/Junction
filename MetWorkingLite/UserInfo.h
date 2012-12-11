//
//  UserInfo.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseUserInfo.h"

@interface UserInfo : ParseUserInfo <PFObjectFactory>

@property (nonatomic) NSString * username;
@property (nonatomic) NSString * password;
@property (nonatomic) NSString * email;
@property (nonatomic) NSString * linkedInString;
@property (nonatomic) NSString * headline;
@property (nonatomic) NSString * position;
@property (nonatomic) NSMutableSet * friends;
@property (nonatomic) UIImage * photo;
@property (nonatomic) NSString * photoURL;
@property (nonatomic) NSString * industry;
@property (nonatomic) NSString * summary;
@property (nonatomic) NSString * location;
@property (nonatomic) NSArray * specialties;
//@property (nonatomic) NSArray * educations;
@property (nonatomic) NSArray * currentPositions;
@property (nonatomic, assign) int numberOfFields;
@property (nonatomic) PFUser * pfUser;
@property (nonatomic) NSString * pfUserID; // repeated from PFUser
@property (nonatomic, strong) PFObject * pfObject;

+(void)FindUserInfoFromParse:(UserInfo*)userInfo withBlock:(void (^)(UserInfo * result, NSError * error))queryCompletedWithResults;
+(void)UpdateUserInfoToParse:(UserInfo*)userInfo;

@end
