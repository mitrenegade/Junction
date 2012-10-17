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
@synthesize headline;
@synthesize position;
@synthesize location;
@synthesize industry;
@synthesize summary;
@synthesize currentPositions;
//@synthesize educations;
@synthesize specialties;
@synthesize numberOfFields;
@synthesize parseID;

-(id)init {
    self = [super init];
    self.friends = [[NSMutableSet alloc] init];
    self.numberOfFields = 6; // displayable text fields
    return self;
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
    [aCoder encodeObject: headline forKey:@"headline"];
    [aCoder encodeObject: position forKey:@"position"];
    [aCoder encodeObject: location forKey:@"location"];
    [aCoder encodeObject: industry forKey:@"industry"];
    [aCoder encodeObject: summary forKey:@"summary"];
    [aCoder encodeObject: currentPositions forKey:@"currentPositions"];
    [aCoder encodeObject: specialties forKey:@"specialties"];
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
        [self setHeadline:[aDecoder decodeObjectForKey:@"headline"]];
        [self setPosition:[aDecoder decodeObjectForKey:@"position"]];
        [self setLocation:[aDecoder decodeObjectForKey:@"location"]];
        [self setIndustry:[aDecoder decodeObjectForKey:@"industry"]];
        [self setSummary:[aDecoder decodeObjectForKey:@"summary"]];
        [self setCurrentPositions:[aDecoder decodeObjectForKey:@"currentPositions"]];
        [self setSpecialties:[aDecoder decodeObjectForKey:@"specialties"]];
    }
    return self;
}

- (PFObject *)toPFObject {
    PFObject *junctionPFObject = [[PFObject alloc] initWithClassName:@"UserInfo"];
    if (username)
        [junctionPFObject setObject:username forKey:@"username"];
    if (password)
        [junctionPFObject setObject:password forKey:@"password"];
    if (email)
        [junctionPFObject setObject:email forKey:@"email"];
    if (linkedInString)
        [junctionPFObject setObject:linkedInString forKey:@"linkedInString"];
    if (headline)
        [junctionPFObject setObject:headline forKey:@"headline"];
    if (position)
        [junctionPFObject setObject:position forKey:@"position"];
    if (industry)
        [junctionPFObject setObject:industry forKey:@"industry"];
    if (summary)
        [junctionPFObject setObject:summary forKey:@"summary"];
    if (location)
        [junctionPFObject setObject:location forKey:@"location"];
    if (parseID)
        [junctionPFObject setObject:parseID forKey:@"parseID"];
    
    return junctionPFObject;
}

- (id)fromPFObject:(PFObject *)obj {
    
    username = [obj objectForKey:@"username"];
    password = [obj objectForKey:@"password"];
    email = [obj objectForKey:@"email"];
    linkedInString = [obj objectForKey:@"linkedInString"];
    headline = [obj objectForKey:@"headline"];
    position = [obj objectForKey:@"position"];
    industry = [obj objectForKey:@"industry"];
    summary = [obj objectForKey:@"summary"];
    location = [obj objectForKey:@"location"];
    parseID = [obj objectForKey:@"parseID"];
    
    return [super fromPFObject:obj];
}

@end
