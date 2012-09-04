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
@property (nonatomic) NSMutableSet * friends;
@property (nonatomic) UIImage * photo;

@end
