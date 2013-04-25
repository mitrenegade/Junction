//
//  Chat.m
//  Junction
//
//  Created by Bobby Ren on 1/1/13.
//
//

#import "Chat.h"

#define CLASSNAME @"Chat"

@implementation Chat

@synthesize message;
@synthesize sender;
@synthesize pfObject;
@synthesize className;
@synthesize chatChannel;
@synthesize hasBeenSeen;
//@synthesize userInfo;

-(id)init {
    self = [super init];
    [self setClassName:CLASSNAME];
    // if we init a userInfo, it must have a new/empty pfObject
    // userInfo objects created from Parse are generated by initWithPFObject which uses fromPFObject
    PFObject *newPFObject = [[PFObject alloc] initWithClassName:CLASSNAME];
    [self setPfObject:newPFObject];
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
    // returns current object
    if (pfObject)
        return pfObject;
    else {
        // do not allocate; returning nil should indicate need to find object
        return nil;
    }
    return pfObject;
}

-(PFObject*)toPFObject {
    // for a pulse we only need to save the pfUser and the location
    // returns current pfObject but with updated coordinate and user
    @try {
        [self.pfObject setObject:sender forKey:@"sender"];
        [self.pfObject setObject:message forKey:@"message"];
        [self.pfObject setObject:chatChannel forKey:@"chatChannel"];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception in trying to convert to PFObject! exception: %@", exception);
        return nil;
    }
    return self.pfObject;
}

- (id)fromPFObject:(PFObject *)pObject {
    [self setPfObject:pObject];
    [self setClassName:pObject.className];
    [self setSender:[pObject objectForKey:@"sender"]];
    [self setMessage:[pObject objectForKey:@"message"]];
    [self setChatChannel:[pObject objectForKey:@"chatChannel"]];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.sender forKey:@"sender"];
    [aCoder encodeObject:self.chatChannel forKey:@"chatChannel"];
//    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        [self setMessage:[aDecoder decodeObjectForKey:@"message"]];
        [self setSender:[aDecoder decodeObjectForKey:@"sender"]];
        [self setChatChannel:[aDecoder decodeObjectForKey:@"chatChannel"]];
//        [self setUserInfo:[aDecoder decodeObjectForKey:@"userInfo"]];
    }
    return self;
}

+(NSString*)getClassName {
    return CLASSNAME;
}

@end
