//
//  UserInfo.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"
#import "AWSHelper.h"
#import "Constants.h"
#import "UIImage+GaussianBlur.h"

@implementation UserInfo
@synthesize username, password, email;
@synthesize linkedInString;
@synthesize friends;
@synthesize photo;
@synthesize photoURL;
@synthesize photoBlur;
@synthesize photoBlurURL;
@synthesize headline;
@synthesize position;
@synthesize location;
@synthesize industry;
@synthesize company;
@synthesize summary;
@synthesize lookingFor;
@synthesize currentPositions;
//@synthesize educations;
@synthesize specialties;
@synthesize pfUser;
@synthesize pfUserID;
@synthesize pfObject;
@synthesize className;
@synthesize talkAbout;
@synthesize photoBlurThumb, photoBlurThumbURL, photoThumb, photoThumbURL;
@synthesize isVisible;

#define CLASSNAME @"UserInfo"

-(id)init {
    self = [super init];
    self.friends = [[NSMutableSet alloc] init];
    [self setClassName:CLASSNAME];
    // if we init a userInfo, it must have a new/empty pfObject
    // userInfo objects created from Parse are generated by initWithPFObject which uses fromPFObject
    PFObject *newPFObject = [[PFObject alloc] initWithClassName:CLASSNAME];
    [self setPfObject:newPFObject];
    return self;
}

-(PFObject*)pfObject {
    // returns current object
    if (pfObject)
        return pfObject;
    else {
        // do not allocate; returning nil should indicate need to find object
        return nil;
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
//    [aCoder encodeObject: photoURL forKey:@"photoURL"];
    [aCoder encodeObject: UIImagePNGRepresentation(photo) forKey:@"photoBlurData"];
//    [aCoder encodeObject: photoURL forKey:@"photoBlurURL"];
    [aCoder encodeObject: headline forKey:@"headline"];
    [aCoder encodeObject: position forKey:@"position"];
    [aCoder encodeObject: location forKey:@"location"];
    [aCoder encodeObject: company forKey:@"company"];
    [aCoder encodeObject: industry forKey:@"industry"];
    [aCoder encodeObject: summary forKey:@"summary"];
    [aCoder encodeObject: lookingFor forKey:@"lookingFor"];
    [aCoder encodeObject: talkAbout forKey:@"talkAbout"];
    [aCoder encodeObject: currentPositions forKey:@"currentPositions"];
    [aCoder encodeObject: specialties forKey:@"specialties"];
    //[aCoder encodeObject: pfUser forKey:@"pfUser"];
    [aCoder encodeObject:pfUserID forKey:@"pfUserID"];
    //    [aCoder encodeObject: educations forKey:@"educations"];
    [aCoder encodeBool:isVisible forKey:@"isVisible"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {    
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setPassword:[aDecoder decodeObjectForKey:@"password"]];
        [self setEmail:[aDecoder decodeObjectForKey:@"email"]];
        [self setLinkedInString:[aDecoder decodeObjectForKey:@"linkedInString"]];
        [self setFriends:[aDecoder decodeObjectForKey:@"friends"]];
        [self setPhoto:[UIImage imageWithData:[aDecoder decodeObjectForKey:@"photoData"]]];
//        [self setPhotoURL:[aDecoder decodeObjectForKey:@"photoURL"]];
        [self setPhotoBlur:[UIImage imageWithData:[aDecoder decodeObjectForKey:@"photoBlurData"]]];
//        [self setPhotoURL:[aDecoder decodeObjectForKey:@"photoBlurURL"]];
        [self setHeadline:[aDecoder decodeObjectForKey:@"headline"]];
        [self setPosition:[aDecoder decodeObjectForKey:@"position"]];
        [self setLocation:[aDecoder decodeObjectForKey:@"location"]];
        [self setCompany:[aDecoder decodeObjectForKey:@"company"]];
        [self setIndustry:[aDecoder decodeObjectForKey:@"industry"]];
        [self setSummary:[aDecoder decodeObjectForKey:@"summary"]];
        [self setLookingFor:[aDecoder decodeObjectForKey:@"lookingFor"]];
        [self setTalkAbout:[aDecoder decodeObjectForKey:@"talkAbout"]];
        [self setCurrentPositions:[aDecoder decodeObjectForKey:@"currentPositions"]];
        [self setSpecialties:[aDecoder decodeObjectForKey:@"specialties"]];
        //[self setPfUser:[aDecoder decodeObjectForKey:@"pfUser"]];
        [self setPfUserID:[aDecoder decodeObjectForKey:@"pfUserID"]];
        [self setIsVisible:[aDecoder decodeBoolForKey:@"isVisible"]];
    }
    return self;
}

- (PFObject *)toPFObject {
    //PFObject *junctionPFObject = [[PFObject alloc] initWithClassName:@"UserInfo"];
    @try {
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
        // don't save photo data, and don't save url because amazon urls expire
//        if (photo)
//            [self.pfObject setObject:UIImagePNGRepresentation(photo) forKey:@"photoData"];
//        if (photoURL)
//            [self.pfObject setObject:photoURL forKey:@"photoURL"];
//        if (photoBlurURL)
//            [self.pfObject setObject:photoURL forKey:@"photoBlurURL"];
        if (position)
            [self.pfObject setObject:position forKey:@"position"];
        if (company)
            [self.pfObject setObject:company forKey:@"company"];
        if (industry)
            [self.pfObject setObject:industry forKey:@"industry"];
        if (summary)
            [self.pfObject setObject:summary forKey:@"summary"];
        if (lookingFor)
            [self.pfObject setObject:lookingFor forKey:@"lookingFor"];
        if (talkAbout)
            [self.pfObject setObject:talkAbout forKey:@"talkAbout"];
        if (location)
            [self.pfObject setObject:location forKey:@"location"];
        if (currentPositions) {
            [self.pfObject setObject:currentPositions forKey:@"currentPositions"];
        }
        if (pfUserID)
            [self.pfObject setObject:pfUserID forKey:@"pfUserID"];
        if (pfUser)
            [self.pfObject setObject:pfUser forKey:@"pfUser"];
        
        [self.pfObject setObject:[NSNumber numberWithBool:isVisible] forKey:@"isVisible"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in UserInfo.toPFObject! %@", exception.description);
        return nil;
    }
    
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
    //photoURL = [obj objectForKey:@"photoURL"];
    /*
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    if (image)
        photo = image;
    else
        photo = [UIImage imageNamed:@"graphic_nopic"];
     */
    //photoBlurURL = [obj objectForKey:@"photoBlurURL"];
    //NSLog(@"Photo: %@ blur: %@", photoURL, photoBlurURL);
    /*
    UIImage * imageBlur = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoBlurURL]]];
    if (imageBlur)
        photoBlur = imageBlur;
    else
        photoBlur = [UIImage imageNamed:@"graphic_nopic"];
     */
    position = [obj objectForKey:@"position"];
    industry = [obj objectForKey:@"industry"];
    company = [obj objectForKey:@"company"];
    summary = [obj objectForKey:@"summary"];
    lookingFor = [obj objectForKey:@"lookingFor"];
    talkAbout = [obj objectForKey:@"talkAbout"];
    location = [obj objectForKey:@"location"];
    pfUserID = [obj objectForKey:@"pfUserID"];
    pfUser = [obj objectForKey:@"pfUser"];
    id currpos = [obj objectForKey:@"currentPositions"];
    currentPositions = [[NSMutableArray alloc] initWithArray:currpos];
    
    isVisible = [[obj objectForKey:@"isVisible"] boolValue];
    
    return [super fromPFObject:obj];
}

+(void)FindUserInfoFromParse:(UserInfo*)userInfo withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults{
    PFCachePolicy policy = kPFCachePolicyNetworkOnly;
    PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
    [query setCachePolicy:policy];
    
    PFUser * pfUser = userInfo.pfUser;
    if (pfUser) {
        NSLog(@"FindUserInfo using pfUser");
        // add user constraint
        [query whereKey:@"pfUser" equalTo:pfUser];
    }
    else if (userInfo.pfUserID) {
        NSString * pfUserID = userInfo.pfUserID;
        NSLog(@"FindUserInfo using pfUserID %@", pfUserID);
        // add user constraint
        [query whereKey:@"pfUserID" equalTo:pfUserID];
    }
    /*
    else if (userInfo.linkedInString) {
        NSString * linkedInString = userInfo.linkedInString;
        NSLog(@"FindUserInfo using linkedInString %@", linkedInString);
        // add user constraint
        [query whereKey:@"linkedInString" equalTo:linkedInString];
    }
     */
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

// new login
+(void)GetUserInfoForPFUser:(PFUser*)pfUser withBlock:(void (^)(UserInfo *, NSError *))queryCompletedWithResults{
    PFCachePolicy policy = kPFCachePolicyNetworkOnly;
    PFQuery * query = [PFQuery queryWithClassName:CLASSNAME];
    [query setCachePolicy:policy];
    [query whereKey:@"pfUser" equalTo:pfUser];
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
                UserInfo * userInfo = [[UserInfo alloc] initWithPFObject:object];
                queryCompletedWithResults(userInfo, error);
            }
        }
    }];
    
}

-(void)savePhotoToAWS:(UIImage*)newPhoto withBlock:(void (^)(BOOL))photoSaved andBlur:(UIImage*)blurPhoto withBlock:(void (^)(BOOL))blurSaved {
    // AWSHelper uploadImage must always be on main thread!
    NSString * name =[NSString stringWithFormat:@"%@", self.linkedInString];
    if (newPhoto) {
        NSLog(@"SavePhotoToAWS: name %@ photo %x", name, newPhoto);
        [AWSHelper uploadImage:newPhoto withName:name toBucket:PHOTO_BUCKET withCallback:^(NSString *url) {
            NSLog(@"New URL for photo: %@", url);
            self.photoURL = url;
            self.photo = newPhoto;
            photoSaved(YES);
        }];
    }
    
    if (blurPhoto) {
        [AWSHelper uploadImage:blurPhoto withName:name toBucket:PHOTO_BLUR_BUCKET withCallback:^(NSString *url) {
            NSLog(@"New URL for photo blur: %@", url);
            self.photoBlurURL = url;
            self.photoBlur = blurPhoto;
            blurSaved(YES);
        }];
    }
}

-(void)saveThumbsToAWSSerial:(UIImage*)newPhoto andBlur:(UIImage*)blurPhoto withBlock:(void (^)(BOOL))photosSaved {
    NSString * name =[NSString stringWithFormat:@"%@", self.linkedInString];
    if (newPhoto) {
        [AWSHelper uploadImage:newPhoto withName:name toBucket:PHOTO_THUMB_BUCKET withCallback:^(NSString *url) {
            NSLog(@"New URL for photo thumb: %@", url);
            photoThumbURL = url;
            self.photo = newPhoto;
            if (blurPhoto) {
                [AWSHelper uploadImage:blurPhoto withName:name toBucket:PHOTO_BLUR_THUMB_BUCKET withCallback:^(NSString *url) {
                    NSLog(@"New URL for photo blur thumb: %@", url);
                    photoBlurThumbURL = url;
                    self.photoBlurThumb = blurPhoto;
                    photosSaved(YES);
                }];
            }
            else {
                photosSaved(YES);
            }
        }];
    }
}

-(void)savePhotoToAWSSerial:(UIImage*)newPhoto andBlur:(UIImage*)blurPhoto withBlock:(void (^)(BOOL))photosSaved {
    // AWSHelper uploadImage must always be on main thread!
    // make sure both photos are saved
    NSString * name =[NSString stringWithFormat:@"%@", self.linkedInString];
    if (newPhoto) {
        [AWSHelper uploadImage:newPhoto withName:name toBucket:PHOTO_BUCKET withCallback:^(NSString *url) {
            NSLog(@"New URL for photo: %@", url);
            photoURL = url;
            self.photo = newPhoto;
            if (blurPhoto) {
                [AWSHelper uploadImage:blurPhoto withName:name toBucket:PHOTO_BLUR_BUCKET withCallback:^(NSString *url) {
                    NSLog(@"New URL for photo blur: %@", url);
                    photoBlurURL = url;
                    self.photoBlur = blurPhoto;
                    photosSaved(YES);
                }];
            }
            else {
                photosSaved(YES);
            }
        }];
    }
}

-(NSString*)photoURL {
    if (photoURL == nil) {
        // generate new link from amazon
        if (self.linkedInString == nil)
            return nil;
        photoURL = [AWSHelper getURLForKey:self.linkedInString inBucket:PHOTO_BUCKET];
        NSLog(@"New photoURL generated from AWS: %@", photoURL);
    }
    return photoURL;
}

-(NSString*)photoBlurURL {
    if (photoBlurURL == nil) {
        // generate new link from amazon
        if (self.linkedInString == nil)
            return nil;
        photoBlurURL = [AWSHelper getURLForKey:self.linkedInString inBucket:PHOTO_BLUR_BUCKET];
        NSLog(@"New photoBlurURL generated from AWS: %@", photoBlurURL);
    }
    return photoBlurURL;
}

-(NSString*)photoThumbURL {
    if (photoThumbURL == nil) {
        // generate new link from amazon
        if (self.linkedInString == nil)
            return nil;
        photoThumbURL = [AWSHelper getURLForKey:self.linkedInString inBucket:PHOTO_THUMB_BUCKET];
        NSLog(@"New photoThumbURL generated from AWS: %@", photoThumbURL);
    }
    return photoThumbURL;
}

-(NSString*)photoBlurThumbURL {
    if (photoBlurThumbURL == nil) {
        // generate new link from amazon
        if (self.linkedInString == nil)
            return nil;
        photoBlurThumbURL = [AWSHelper getURLForKey:self.linkedInString inBucket:PHOTO_BLUR_THUMB_BUCKET];
        NSLog(@"New photoBlurThumbURL generated from AWS: %@", photoBlurThumbURL);
    }
    return photoBlurThumbURL;
}

@end
