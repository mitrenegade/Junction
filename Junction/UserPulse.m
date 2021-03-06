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
@synthesize pfObject, pfUser, pfUserID;
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
    @try {
        [self.pfObject setObject:pfUser forKey:@"pfUser"];
        [self.pfObject setObject:currentPoint forKey:@"pfGeopoint"];
        [self.pfObject setObject:pfUserID forKey:@"pfUserID"];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception in trying to convert UserPulse to PFObject!");
        return nil;
    }
    
    NSLog(@"Creating new pulse PFObject with pfUserID %@", pfUserID);
    
    return self.pfObject;
}

- (id)fromPFObject:(PFObject *)pObject {
    [self setPfObject:pObject];
    [self setClassName:pObject.className];
    [self setPfUser:[pObject objectForKey:@"pfUser"]];
    [self setPfUserID:[pObject objectForKey:@"pfUserID"]];
    
    PFGeoPoint * geoPoint = [pObject objectForKey:@"pfGeopoint"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    [self setCoordinate:coord];
    return self;
}

+(void)DoUserPulseWithLocation:(CLLocation*)location forUser:(UserInfo*)myUserInfo withBlock:(void (^)(BOOL success))pulseCompleted {
    // relationship of user and pulse is one-to-one
    // the pulse is a newly created object
    // so if the object for this user already exists, we replace it
    // we can't just do a save call
    // returns success of pulsing/savinng
    
    if (myUserInfo.isVisible == NO) {
        NSLog(@"No! I should be invisible!");
    }
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
    if (myUserInfo.userPulse) {
        // already has a userPulse
        UserPulse * userPulse = myUserInfo.userPulse;
        PFObject * pfObject = userPulse.pfObject;
        // todo: can crash here with error 'This object has an outstanding network connection. You have to wait until it's done.'
        // todo: make sure userPulse has saved?
        [pfObject setObject:currentPoint forKey:@"pfGeopoint"];
        [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            pulseCompleted(succeeded);
        }];
        return;
    }
    else {
        PFUser * pfUser = myUserInfo.pfUser;
        
        if (!pfUser) {
            NSLog(@"Oh no! no pfUser!");
            pulseCompleted(NO);
            return;
        }
        
        PFObject * pfObject = nil;
        
        PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
        [query whereKey:@"pfUser" equalTo:pfUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error doing user pulse!");
                pulseCompleted(NO);
            }
            else {
                if ([objects count] == 0) {
                    NSLog(@"No objects found for classname %@ and pfUser %@", CLASSNAME, pfUser);
                    UserPulse * pulse = [[UserPulse alloc] init];
                    // todo: call a pulseFromUserInfo
                    [pulse setPfUser:pfUser];
                    [pulse setPfUserID:pfUser.objectId];
                    [pulse setCoordinate:location.coordinate];
                    //[pulse setLinkedInID:myUserInfo.linkedInString]; // just for information
                    PFObject * pulseObject = [pulse toPFObject];
                    [pulse setPfObject:pulseObject];
                    [myUserInfo setUserPulse:pulse];
                    
                    [pulseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        pulseCompleted(succeeded);
                    }];
                }
                else {
                    id key = @"pfGeopoint";
                    PFObject * oldObject = [objects objectAtIndex:0];
                    NSLog(@"Replacing new value %@ for key %@", currentPoint, key);
                    [oldObject setObject:currentPoint forKey:@"pfGeopoint"];
                    [oldObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        UserPulse * pulse = [[UserPulse alloc] initWithPFObject:oldObject];
                        [myUserInfo setUserPulse:pulse];
                        pulseCompleted(succeeded);
                    }];
                }
            }
        }];
    }
}

+(void)FindUserPulseForUserInfo:(UserInfo*)userInfo withBlock:(void (^)(NSArray *, NSError *))queryCompletedWithResults {
    //NSLog(@"In FindUserPulse");
    // returns a userPulse
    if (!allUserPulses) {
        allUserPulses = [[NSMutableDictionary alloc] init];
    }
    
    if ([allUserPulses objectForKey:userInfo.pfUserID]) {
        // allUserPulses already contains the pulse, so use the pfObject to directly query Parse
        UserPulse * pulse = [allUserPulses objectForKey:userInfo.pfUserID];
        PFObject * pfObject = pulse.pfObject;
        if (!pfObject) {
            pfObject = [pulse toPFObject];
        }
        if (!pfObject) {
            NSLog(@"Could not create pfObject!");
            queryCompletedWithResults(nil, nil);
        }
        @try {
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
        @catch (NSException *exception) {
            NSLog(@"FindUserPulseForUserInfo - userInfo object still being used. Probably trying to update pulse while loading it.");
        }
            
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
        /*
        else if (userInfo.linkedInString) {
            NSString * linkedInString = userInfo.linkedInString;
            NSLog(@"FindUserPulse using linkedInString %@", linkedInString);
            // add user constraint
            [query whereKey:@"linkedInString" equalTo:linkedInString];
        }
         */
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
                    //NSLog(@"pulse->pfUser: %@", pulse.pfUser);
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
