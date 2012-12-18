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

+(NSString*)className {
    return CLASSNAME;
}

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
    // relationship of user and pulse is one-to-one
    // the pulse is a newly created object
    // so if the object for this user already exists, we replace it
    // we can't just do a save call
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
    if (myUserInfo.userPulse) {
        // already has a userPulse
        UserPulse * userPulse = myUserInfo.userPulse;
        PFObject * pfObject = userPulse.pfObject;
        [pfObject setObject:currentPoint forKey:@"pfGeopoint"];
        [pfObject save];
        return;
    }
    else {
        PFUser * pfUser = myUserInfo.pfUser;
        
        if (!pfUser) {
            NSLog(@"Oh no! no pfUser!");
            return;
        }
        
        PFObject * pfObject = nil;
        
        PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
        [query whereKey:@"pfUser" equalTo:pfUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error doing user pulse!");
            }
            else {
                if ([objects count] == 0) {
                    NSLog(@"No objects found for classname %@ and pfUser %@", CLASSNAME, pfUser);
                    UserPulse * pulse = [[UserPulse alloc] init];
                    [pulse setPfUser:pfUser];
                    [pulse setCoordinate:location.coordinate];
                    PFObject * pulseObject = [pulse toPFObject];
                    [pulse setPfObject:pulseObject];
                    [myUserInfo setUserPulse:pulse];
                    
                    [pulseObject save];
                }
                else {
                    id key = @"pfGeopoint";
                    PFObject * oldObject = [objects objectAtIndex:0];
                    NSLog(@"Replacing new value %@ for key %@", currentPoint, key);
                    [oldObject setObject:currentPoint forKey:@"pfGeopoint"];
                    [oldObject save];
                }
            }
        }];
    }
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
