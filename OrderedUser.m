//
//  OrderedUser.m
//  Junction
//
//  Created by Bobby Ren on 2/12/13.
//
//

#import "OrderedUser.h"

@implementation OrderedUser

@synthesize userInfo;
@synthesize weight;

-(id)initWithUserInfo:(UserInfo *)theUserInfo {
    self = [super init];
    if (self) {
        self.userInfo = theUserInfo;
    }
    return self;
}

-(NSComparisonResult)compare:(OrderedUser*)otherUser {
    
    if (self.weight > otherUser.weight)
        return NSOrderedDescending;
    else if (self.weight == otherUser.weight)
        return NSOrderedSame;
    
    return NSOrderedAscending;
}
@end
