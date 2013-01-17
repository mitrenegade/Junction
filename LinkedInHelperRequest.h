//
//  LinkedInHelperRequest.h
//  Junction
//
//  Created by Bobby Ren on 1/15/13.
//
//

#import "OAMutableURLRequest.h"
#import "OAuthConsumer.h"
#import "OAuthLoginView.h"

@interface LinkedInHelperRequest:NSObject

// LinkedInHelper success and failure blocks
typedef void (^lhSuccessBlock)(BOOL, NSData *);
typedef void (^lhFailureBlock)(BOOL, NSError *);

@property (nonatomic, strong) lhSuccessBlock successBlock;
@property (nonatomic, strong) lhFailureBlock failureBlock;

@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) OAConsumer * storedOAuthConsumer;
@property (nonatomic, strong) OAToken * storedOAuthAccessToken;

-(id)initWithOAuthConsumer:(OAConsumer*)oauthConsumer andOAuthAccessToken:(OAToken*)oauthAccessToken;
- (void)doRequestForEndpoint:(NSString*)endpoint withParams:(NSMutableDictionary*)params withBlockForSuccess:(lhSuccessBlock)success failure:(lhFailureBlock)failure;

@end
