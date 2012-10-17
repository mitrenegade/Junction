//
//  UserPulse.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/1/12.
//
//

#import "UserPulse.h"
#import "ParseHelper.h"
#import "UserInfo.h"

@implementation UserPulse

@synthesize coordinate;
@synthesize pfObject, pfUser;
@synthesize className;

#define CLASSNAME @"UserPulse"

-(id) init {
    self = [super init];
    if (self)
    {
        [self setClassName:CLASSNAME];
    }
    return self;
}

- (id)initWithPFObject:(PFObject *)object {
    self = [super init];
    if (self)
    {
        [self fromPFObject:object];
    }
    return self;
}


-(PFObject*)toPFObject {
    // for a pulse we only need to save the pfUser and the location
    
    PFObject *newObject = [[PFObject alloc] initWithClassName:CLASSNAME];
    
    // Create a PFGeoPoint using the user's location
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    [newObject setObject:pfUser forKey:@"pfUser"];
    [newObject setObject:currentPoint forKey:@"pfGeopoint"];
    
    return newObject;
}

- (id)fromPFObject:(PFObject *)pObject {
    [self setClassName:pObject.className];
    [self setPfUser:[pObject objectForKey:@"pfUser"]];
    
    PFGeoPoint * geoPoint = [pObject objectForKey:@"pfGeopoint"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    [self setCoordinate:coord];
    return self;
}

+(void)DoUserPulseWithLocation:(CLLocation*)location forUser:(UserInfo*)myUserInfo {
    UserPulse * pulse = [[UserPulse alloc] init];
    [pulse setCoordinate:location.coordinate];
    PFUser * pfUser = myUserInfo.pfUser;
    
    if (!pfUser) {
        NSLog(@"Oh no! no pfUser!");
        return;
    }
    else {
        [pulse setPfUser:pfUser];
    }

    PFObject * pulseObject = [pulse toPFObject];
    
    [ParseHelper updateParseObject:pulseObject forUser:pfUser withBlock:^(BOOL finished, NSError * error) {
        if (finished) {
            NSLog(@"Updated parse object %@ for user %@!", pulseObject, pfUser);
        }
        else {
            NSLog(@"Error: %@", [error description]);
        }
    }];
}

+(void)FindUserPulseForUserInfo:(UserInfo*)userInfo withBlock:(void (^)(NSArray *, NSError *))queryCompletedWithResults {
    PFCachePolicy policy = kPFCachePolicyCacheThenNetwork;
    PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
    [query setCachePolicy:policy];
    
    PFUser * pfUser = userInfo.pfUser;
    if (!pfUser) {
        NSLog(@"No pfUser! cannot query pulse for userInfo");
        return;
    }
    
    // add user constraint
    [query whereKey:@"pfUser" equalTo:pfUser];
    
    [query findObjectsInBackgroundWithBlock:queryCompletedWithResults];
}
@end
