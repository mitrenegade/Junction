//
//  LinkedInHelperRequest.m
//  Junction
//
//  Created by Bobby Ren on 1/15/13.
//
//

#import "LinkedInHelperRequest.h"
#import "OADataFetcher.h"
#import "JSONKit.h"

@implementation LinkedInHelperRequest

@synthesize successBlock, failureBlock;
@synthesize storedOAuthAccessToken, storedOAuthConsumer;

-(id)initWithOAuthConsumer:(OAConsumer*)oauthConsumer andOAuthAccessToken:(OAToken*)oauthAccessToken {
    
    self = [super init];
    if (self) {
        self.storedOAuthConsumer = oauthConsumer;
        self.storedOAuthAccessToken = oauthAccessToken;
    }
    return self;
}

- (void)doRequestForEndpoint:(NSString*)endpoint withParams:(NSMutableDictionary*)params withBlockForSuccess:(lhSuccessBlock)success failure:(lhFailureBlock)failure

{
    NSLog(@"Making linkedIn request to endpoint %@", endpoint);
    NSURL *url = [NSURL URLWithString:endpoint];
    
    self.successBlock = success;
    self.failureBlock = failure;
    
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:storedOAuthConsumer
                                       token:storedOAuthAccessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinish:)
                  didFailSelector:@selector(requestTokenTicket:didFail:)];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    /*
    // string is returned as json
    // for example:
     {
     "_total": 1,
     "values": ["http://m3.licdn.com/mpr/mprx/0_0tEWfGVa22e8ORVXJ_wbEi4ueaV8JeVX4TqXd_6hLRUiOWeEsCI5wWObc7x"]
     }
     */
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"String: %@", string);
    self.successBlock(YES, data);
}

-(void)requestTokenTicket:(OAServiceTicket*)ticket didFail:(NSError*)error {
    self.failureBlock(YES, error);
}
@end
