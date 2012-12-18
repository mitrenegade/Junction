//
//  Kumulos.h
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Aug 20, 2012
//  Copyright Neroh All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libKumulos.h"


@class Kumulos;
@protocol KumulosDelegate <kumulosProxyDelegate>
@optional

 
- (void) kumulosAPI:(Kumulos*)kumulos apiOperation:(KSAPIOperation*)operation registerUserDidCompleteWithResult:(NSNumber*)newRecordID;

@end

@interface Kumulos : kumulosProxy {
    NSString* theAPIKey;
    NSString* theSecretKey;
}

-(Kumulos*)init;
-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey;

   
-(KSAPIOperation*) registerUserWithUsername:(NSString*)username andEmail:(NSString*)email;
    
            
@end