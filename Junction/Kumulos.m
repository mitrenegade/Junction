//
//  Kumulos.m
//  Kumulos
//
//  Created by Kumulos Bindings Compiler on Aug 20, 2012
//  Copyright Neroh All rights reserved.
//

#import "Kumulos.h"

@implementation Kumulos

-(Kumulos*)init {

    if ([super init]) {
        theAPIKey = @"wmvzzd586bbjkz550cfzkgssb0fggs28";
        theSecretKey = @"b1qgzwhj";
        useSSL = NO;
    }

    return self;
}

-(Kumulos*)initWithAPIKey:(NSString*)APIKey andSecretKey:(NSString*)secretKey{
    if([super init]){
        theAPIKey = [APIKey copy];
        theSecretKey = [secretKey copy];
    }
    return self;
 }


-(KSAPIOperation*) registerUserWithUsername:(NSString*)username andEmail:(NSString*)email{

    
     NSMutableDictionary* theParams = [[NSMutableDictionary alloc]init];
            [theParams setValue:username forKey:@"username"];
                    [theParams setValue:email forKey:@"email"];
                        
    KSAPIOperation* newOp = [[KSAPIOperation alloc]initWithAPIKey:theAPIKey andSecretKey:theSecretKey andMethodName:@"registerUser" andParams:theParams];
    [newOp setDelegate:self];
    [newOp setUseSSL:useSSL];
            
    //we pass the method signature for the kumulosProxy callback on this thread
 
    [newOp setCallbackSelector:@selector( kumulosAPI: apiOperation: registerUserDidCompleteWithResult:)];
    [newOp setSuccessCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didCompleteWithResult:)]];
    [newOp setErrorCallbackMethodSignature:[self methodSignatureForSelector:@selector(apiOperation: didFailWithError:)]];
    [opQueue addOperation:newOp];
 
    return newOp;
    
}

@end