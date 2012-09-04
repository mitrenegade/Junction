//
//  UserInfo.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize username, email;
@synthesize linkedInString;
@synthesize friends;
@synthesize photo;

-(id)init {
    self = [super init];
    friends = [[NSMutableSet alloc] init];
    return self;
}

-(void)loginWithUsername:(NSString*)_username {
    [self setUsername:_username];
}

-(BOOL)isFriendsWith:(NSString*)friendName {
    if ([friends containsObject:friendName])
        return YES;
    return NO;
}
@end
