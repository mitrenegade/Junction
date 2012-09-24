//
//  UserInfo.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic) NSString * username;
@property (nonatomic) NSString * email;
@property (nonatomic) NSString * linkedInString;
@property (nonatomic) NSString * headline;
@property (nonatomic) NSString * position;
@property (nonatomic) NSMutableSet * friends;
@property (nonatomic) UIImage * photo;
@property (nonatomic) NSString * industry;
@property (nonatomic) NSString * summary;
@property (nonatomic) NSString * location;
@property (nonatomic) NSArray * specialties;
//@property (nonatomic) NSArray * educations;
@property (nonatomic) NSArray * currentPositions;
@property (nonatomic, assign) int numberOfFields;
@end
