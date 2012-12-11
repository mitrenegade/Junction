//
//  UserInfo.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize username, password, email;
@synthesize linkedInString;
@synthesize friends;
@synthesize photo;
@synthesize photoURL;
@synthesize headline;
@synthesize position;
@synthesize location;
@synthesize industry;
@synthesize summary;
@synthesize currentPositions;
//@synthesize educations;
@synthesize specialties;
@synthesize numberOfFields;
@synthesize pfUser;
@synthesize pfUserID;
@synthesize pfObject;
@synthesize className;

#define CLASSNAME @"UserInfo"

-(id)init {
    self = [super init];
    self.friends = [[NSMutableSet alloc] init];
    self.numberOfFields = 6; // displayable text fields
    [self setClassName:CLASSNAME];
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

-(void)loginWithUsername:(NSString*)_username {
    [self setUsername:_username];
}

-(BOOL)isFriendsWith:(NSString*)friendName {
    if ([friends containsObject:friendName])
        return YES;
    return NO;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject: username forKey:@"username"];
    [aCoder encodeObject: password forKey:@"password"];
    [aCoder encodeObject: email forKey:@"email"];
    [aCoder encodeObject: linkedInString forKey:@"linkedInString"];
    [aCoder encodeObject: friends forKey:@"friends"];
    [aCoder encodeObject: UIImagePNGRepresentation(photo) forKey:@"photoData"];
    [aCoder encodeObject: photoURL forKey:@"photoURL"];
    [aCoder encodeObject: headline forKey:@"headline"];
    [aCoder encodeObject: position forKey:@"position"];
    [aCoder encodeObject: location forKey:@"location"];
    [aCoder encodeObject: industry forKey:@"industry"];
    [aCoder encodeObject: summary forKey:@"summary"];
    [aCoder encodeObject: currentPositions forKey:@"currentPositions"];
    [aCoder encodeObject: specialties forKey:@"specialties"];
    //[aCoder encodeObject: pfUser forKey:@"pfUser"];
    [aCoder encodeObject:pfUserID forKey:@"pfUserID"];
    //    [aCoder encodeObject: educations forKey:@"educations"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {    
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setPassword:[aDecoder decodeObjectForKey:@"password"]];
        [self setEmail:[aDecoder decodeObjectForKey:@"email"]];
        [self setLinkedInString:[aDecoder decodeObjectForKey:@"linkedInString"]];
        [self setFriends:[aDecoder decodeObjectForKey:@"friends"]];
        [self setPhoto:[UIImage imageWithData:[aDecoder decodeObjectForKey:@"photoData"]]];
        [self setPhotoURL:[aDecoder decodeObjectForKey:@"photoURL"]];
        [self setHeadline:[aDecoder decodeObjectForKey:@"headline"]];
        [self setPosition:[aDecoder decodeObjectForKey:@"position"]];
        [self setLocation:[aDecoder decodeObjectForKey:@"location"]];
        [self setIndustry:[aDecoder decodeObjectForKey:@"industry"]];
        [self setSummary:[aDecoder decodeObjectForKey:@"summary"]];
        [self setCurrentPositions:[aDecoder decodeObjectForKey:@"currentPositions"]];
        [self setSpecialties:[aDecoder decodeObjectForKey:@"specialties"]];
        //[self setPfUser:[aDecoder decodeObjectForKey:@"pfUser"]];
        [self setPfUserID:[aDecoder decodeObjectForKey:@"pfUserID"]];
    }
    return self;
}

- (PFObject *)toPFObject {
    //PFObject *junctionPFObject = [[PFObject alloc] initWithClassName:@"UserInfo"];
    if (username)
        [self.pfObject setObject:username forKey:@"username"];
    if (password)
        [self.pfObject setObject:password forKey:@"password"];
    if (email)
        [self.pfObject setObject:email forKey:@"email"];
    if (linkedInString)
        [self.pfObject setObject:linkedInString forKey:@"linkedInString"];
    if (headline)
        [self.pfObject setObject:headline forKey:@"headline"];
    if (photo)
        [self.pfObject setObject:UIImagePNGRepresentation(photo) forKey:@"photoData"];
    if (photoURL)
        [self.pfObject setObject:photoURL forKey:@"photoURL"];
    if (position)
        [self.pfObject setObject:position forKey:@"position"];
    if (industry)
        [self.pfObject setObject:industry forKey:@"industry"];
    if (summary)
        [self.pfObject setObject:summary forKey:@"summary"];
    if (location)
        [self.pfObject setObject:location forKey:@"location"];
    if (pfUserID)
        [self.pfObject setObject:pfUserID forKey:@"pfUserID"];
    if (pfUser)
        [self.pfObject setObject:pfUser forKey:@"pfUser"];
    
    NSLog(@"Created new UserInfo for user %@ pfUserID %@", username, pfUserID);
    
    return self.pfObject;
}

- (id)fromPFObject:(PFObject *)obj {
    [self setPfObject:obj];
    
    username = [obj objectForKey:@"username"];
    password = [obj objectForKey:@"password"];
    email = [obj objectForKey:@"email"];
    linkedInString = [obj objectForKey:@"linkedInString"];
    headline = [obj objectForKey:@"headline"];
    UIImage * image = [UIImage imageWithData:[obj objectForKey:@"photoData"]];
    if (image)
        photo = image;
    else
        photo = [UIImage imageNamed:@"graphic_nopic"];
    photoURL = [obj objectForKey:@"photoData"];
    position = [obj objectForKey:@"position"];
    industry = [obj objectForKey:@"industry"];
    summary = [obj objectForKey:@"summary"];
    location = [obj objectForKey:@"location"];
    pfUserID = [obj objectForKey:@"pfUserID"];
    pfUser = [obj objectForKey:@"pfUser"];
    
    return [super fromPFObject:obj];
}

+(void)FindUserInfoFromParse:(UserInfo*)userInfo withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults{
    PFCachePolicy policy = kPFCachePolicyCacheThenNetwork;
    PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
    [query setCachePolicy:policy];
    
    PFUser * pfUser = userInfo.pfUser;
    if (pfUser) {
        NSLog(@"FindUserPulse using pfUser");
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
            NSLog(@"FindUserInfoFromParse: Query resulted in error!");
            queryCompletedWithResults(nil, error);
        }
        else {
            if ([objects count] == 0) {
                NSLog(@"FindUserInfoFromParse: 0 results");
                queryCompletedWithResults(nil, nil);
            }
            else {
                PFObject * object = [objects objectAtIndex:0];
                [userInfo setPfObject:object];
                queryCompletedWithResults(userInfo, error);
            }
        }
    }];

}

+(void)UpdateUserInfoToParse:(UserInfo*)userInfo {
    [UserInfo FindUserInfoFromParse:userInfo withBlock:^(UserInfo * result, NSError * error) {
        if (result) {
            PFObject * pfObject = [result toPFObject];
            [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"UpdateUserInfoToParse Saving userInfo %@ succeeded", userInfo);
                }
                else {
                    NSLog(@"UpdateUserInfoToParse error: %@", error);
                }
            }];
        }
        else {
            NSLog(@"UpdateUserInfoToParse Error finding userInfo on Parse!");
        }
    }];
}

@end
