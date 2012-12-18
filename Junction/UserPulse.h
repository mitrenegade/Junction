//
//  UserPulse.h
//  Junction
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

// hack: queries don't have pfUser so these are unique identifiers. not efficient
@property (nonatomic) NSString * pfUserID; // objectID from pfUser, needed for queries
@property (nonatomic) NSString * linkedInID; // linkedInID, needed for queries
+(void)DoUserPulseWithLocation:(CLLocation*)location forUser:(UserInfo*)userInfo;
+(void)FindUserPulseForUserInfo:(UserInfo*)userInfo withBlock:(void (^)(NSArray *, NSError *))queryCompletedWithResults;
+(NSString*)className;
-(ParseLocationAnnotation*)toAnnotation;

@end
