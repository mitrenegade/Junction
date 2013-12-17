//
//  JunctionNotification.h
//  Junction
//
//  Created by Bobby Ren on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#import "PFObjectFactory.h"
#import "UserInfo.h"

@interface JunctionNotification : NSObject <PFObjectFactory>
@property (strong, nonatomic) NSString * className;
//@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString * pfUserID;
@property (strong, nonatomic) NSString * senderPfUserID;
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) PFUser * pfUser;
@property (nonatomic, strong) PFObject *pfObject;

+(void)FindNotificationsForUser:(UserInfo*)userInfo withBlock:(void (^)(NSArray * results, NSError * error))queryCompletedWithResults;

@end
