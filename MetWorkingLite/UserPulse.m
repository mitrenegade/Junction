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
@synthesize pfObject, pfUser, pfUserID, linkedInID;
@synthesize className;

#define CLASSNAME @"UserPulse"
static NSMutableDictionary * allUserPulses;

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
    // uses existing list of user pulses to pull out pfObjects
    // if userPulse exists, the pfObject is directly linked to Parse and can be updated
    //   - the coordinate of the userPulse is updated, then the pfObject is saved
    // if userPulse doesn't exist, then it creates a pulse, converts it to a pfObject, and saves it
    
    if (!allUserPulses) {
        allUserPulses = [[NSMutableDictionary alloc] init];
    }
    
    // create userPulse and add all info from myUserInfo
    UserPulse * pulse = [allUserPulses objectForKey:[myUserInfo pfUserID]];
    if (!pulse) {
        pulse = [[UserPulse alloc] init];
    }
    [pulse setCoordinate:location.coordinate];
    PFUser * pfUser = myUserInfo.pfUser;
    if (!pfUser) {
        NSLog(@"Oh no! no pfUser!");
        return;
    }
    else {
        [pulse setPfUser:pfUser];
    }
    [pulse setPfUserID:myUserInfo.pfUserID];
    [pulse setLinkedInID:myUserInfo.linkedInString];
    [allUserPulses setObject:pulse forKey:[myUserInfo pfUserID]];

    // return an updated or newly allocated pfObject based on the pulse
    PFObject * pulseObject = [pulse toPFObject];
    
    [pulseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"DoUserPulseWithLocation: Updated parse object %@ for user %@!", pulseObject, pfUser);
        }
        else {
            NSLog(@"DoUserPulseWithLocation: Error: %@", [error description]);
        }
    }];
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
