//
//  UserInfo.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize username;
@synthesize linkedInString;
@synthesize friends;
@synthesize photo;
@synthesize email;
@synthesize headline;
@synthesize position;
@synthesize location;
@synthesize industry;
@synthesize summary;
@synthesize currentPositions;
//@synthesize educations;
@synthesize specialties;
@synthesize numberOfFields;

-(id)init {
    self = [super init];
    friends = [[NSMutableSet alloc] init];
    numberOfFields = 6; // displayable text fields
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
    
    [aCoder encodeObject:username forKey:@"username"];
    [aCoder encodeObject: linkedInString forKey:@"linkedInString"];
    [aCoder encodeObject: friends forKey:@"friends"];
    [aCoder encodeObject: UIImagePNGRepresentation(photo) forKey:@"photoData"];
    [aCoder encodeObject: email forKey:@"email"];
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
    
    if ((self = [super init])) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setLinkedInString:[aDecoder decodeObjectForKey:@"linkedInString"]];
        [self setFriends:[aDecoder decodeObjectForKey:@"friends"]];
        [self setPhoto:[UIImage imageWithData:[aDecoder decodeObjectForKey:@"photoData"]]];
        [self setEmail:[aDecoder decodeObjectForKey:@"email"]];
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


@end
