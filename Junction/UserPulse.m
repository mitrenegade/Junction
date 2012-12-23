//
//  UserPulse.m
//  Junction
//
//  Created by Bobby Ren on 10/1/12.
//
//

#import "UserPulse.h"
#import "ParseHelper.h"
#import "UserInfo.h"

@implementation UserPulse

@synthesize coordinate;
@synthesize pfObject, pfUser, pfUserID, linkedInID;
@synthesize className;

#define CLASSNAME @"UserPulse"
static NSMutableDictionary * allUserPulses;

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

-(PFObject*)pfObject {
    // allocates or returns current object
    if (pfObject)
        return pfObject;
    else {
        PFObject *newPFObject = [[PFObject alloc] initWithClassName:CLASSNAME];
        [self setPfObject:newPFObject];
    }
    return pfObject;
}


-(PFObject*)toPFObject {
    // for a pulse we only need to save the pfUser and the location
    // returns current pfObject but with updated coordinate and user
    
    // Create a PFGeoPoint using the user's location
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    [self.pfObject setObject:pfUser forKey:@"pfUser"];
    [self.pfObject setObject:currentPoint forKey:@"pfGeopoint"];
    [self.pfObject setObject:pfUserID forKey:@"pfUserID"];
    [self.pfObject setObject:linkedInID forKey:@"linkedInID"];
    
    NSLog(@"Creating new pulse PFObject with pfUserID %@ linkedInID %@", pfUserID, linkedInID);
    
    return self.pfObject;
}

- (id)fromPFObject:(PFObject *)pObject {
    [self setPfObject:pObject];
    [self setClassName:pObject.className];
    [self setPfUser:[pObject objectForKey:@"pfUser"]];
    [self setPfUserID:[pObject objectForKey:@"pfUserID"]];
    [self setLinkedInID:[pObject objectForKey:@"linkedInID"]];
    
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
                    // todo: call a pulseFromUserInfo
                    [pulse setPfUser:pfUser];
                    [pulse setPfUserID:pfUser.objectId];
                    [pulse setCoordinate:location.coordinate];
                    [pulse setLinkedInID:myUserInfo.linkedInString];
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
    NSLog(@"In FindUserPulse");
    // returns a userPulse
    if (!allUserPulses) {
        allUserPulses = [[NSMutableDictionary alloc] init];
    }
    
    if ([allUserPulses objectForKey:userInfo.pfUserID]) {
        // allUserPulses already contains the pulse, so use the pfObject to directly query Parse
        UserPulse * pulse = [allUserPulses objectForKey:userInfo.pfUserID];
        PFObject * pfObject = [pulse toPFObject];
        [pfObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error) {
                NSLog(@"FindUserPulseForUserInfo: Could not refresh pfObject!");
                queryCompletedWithResults(nil, error);
            }
            else {
                NSArray * queryArray = [NSArray arrayWithObject:[pulse fromPFObject:object]];
                queryCompletedWithResults(queryArray, nil);
            }
        }];
    }
    else {
        // query for the pfObject, and generate a userPulse and save to allUserPulses
        PFCachePolicy policy = kPFCachePolicyCacheThenNetwork;
        PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
        [query setCachePolicy:policy];
        
        PFUser * pfUser = userInfo.pfUser;
        if (pfUser) {
            NSLog(@"FindUserPulse using pfUser %@", pfUser);
            // add user constraint
            [query whereKey:@"pfUser" equalTo:pfUser];
        }
        else if (userInfo.pfUserID) {
            NSString * pfUserID = userInfo.pfUserID;
            NSLog(@"FindUserPulse using pfUserID %@", pfUserID);
            // add user constraint
            [query whereKey:@"pfUserID" equalTo:pfUserID];
        }
        else if (userInfo.linkedInString) {
            NSString * linkedInString = userInfo.linkedInString;
            NSLog(@"FindUserPulse using linkedInString %@", linkedInString);
            // add user constraint
            [query whereKey:@"linkedInString" equalTo:linkedInString];
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"FindUserPulseForUserInfo: findPulse Query resulted in error!");
                queryCompletedWithResults(nil, error);
            }
            else {
                if ([objects count] == 0) {
                    NSLog(@"FindUserPulseForUserInfo: no resulting pulse found for user!");
                    queryCompletedWithResults(nil, nil);
                }
                else {
                    PFObject * object = [objects objectAtIndex:0];
                    UserPulse * pulse = [[UserPulse alloc] initWithPFObject:object];
                    [allUserPulses setObject:pulse forKey:[userInfo pfUserID]];
                    NSArray * queryArray = [NSArray arrayWithObject:pulse];
                    queryCompletedWithResults(queryArray, nil);
                }
            }
        }];
    }
}

-(ParseLocationAnnotation*)toAnnotation {
    // possibly set other attributes such as user name, distance, pin type. Would require subclass of ParseLocationAnnotation
    ParseLocationAnnotation * annotation = [[ParseLocationAnnotation alloc] initWithCoordinate:self.coordinate];
    return annotation;
}
@end
