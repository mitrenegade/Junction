//
//  UserPulse.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/1/12.
//
//  Parse stored, location-enabled, with a user

#import "PFObjectFactory.h"
#import "UserInfo.h"
#import "ParseLocationAnnotation.h"

@interface UserPulse : NSObject <PFObjectFactory>

@property (nonatomic) CLLocationCoordinate2D coordinate;
// parse properties
@property (weak, nonatomic) PFUser * pfUser;
@property (nonatomic, strong) PFObject *pfObject;

+(void)DoUserPulseWithLocation:(CLLocation*)location forUser:(UserInfo*)userInfo;
+(void)FindUserPulseForUserInfo:(UserInfo*)userInfo withBlock:(void (^)(NSArray *, NSError *))queryCompletedWithResults;
+(NSString*)className;
@end
