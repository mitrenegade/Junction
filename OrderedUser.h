//
//  OrderedUser.h
//  Junction
//
//  Created by Bobby Ren on 2/12/13.
//
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface OrderedUser : NSObject 

@property (nonatomic, strong) UserInfo * userInfo;
@property (nonatomic, assign) float weight;

-(id)initWithUserInfo:(UserInfo*)theUserInfo;
-(NSComparisonResult)compare:(OrderedUser*)otherUser;
@end
