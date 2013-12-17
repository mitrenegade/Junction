    //
//  LinkedInHelper.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkedInHelper.h"
#import "AppDelegate.h"
#import "LinkedInHelperRequest.h"

static OAuthLoginView * sharedOAuthLoginView;

@implementation LinkedInHelper

//@synthesize oAuthLoginView;
@synthesize delegate;
@synthesize userID;
@synthesize storedOAuthConsumer;
@synthesize storedOAuthAccessToken;
@synthesize lhRequest;

-(id)init {
    self = [super init];
    if (self) {
        [self loadCachedOAuth];
        return self;
    }
    return nil;
}

-(OAuthLoginView*) loginView 
{    
    if (!sharedOAuthLoginView)
        sharedOAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginViewDidFinish:) 
                                                 name:@"loginViewDidFinish" 
                                               object:nil];
    
    return sharedOAuthLoginView;
}

-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginViewDidFinish"
                                                  object:nil];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    
    // store and cache oauth tokens
    [self setStoredOAuthConsumer:sharedOAuthLoginView.consumer];
    [self setStoredOAuthAccessToken:sharedOAuthLoginView.accessToken];
    [self saveCachedOAuth];
    
    NSLog(@"stored auth: %@ %@", storedOAuthAccessToken, storedOAuthConsumer);    
    
    [self getId];
    //[self profileApiCall]; // required for email
}

-(void)closeLoginView {
    if (sharedOAuthLoginView)
        [sharedOAuthLoginView.view removeFromSuperview];
}

-(void)getId {
    NSString * endpoint = @"http://api.linkedin.com/v1/people/~/id";
    self.lhRequest = [[LinkedInHelperRequest alloc] initWithOAuthConsumer:self.storedOAuthConsumer andOAuthAccessToken:self.storedOAuthAccessToken];
    NSLog(@"DoRequestForEndpoint: %@", endpoint);
    [self.lhRequest doRequestForEndpoint:endpoint withParams:nil withBlockForSuccess:^(BOOL success, NSData * data) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        
        NSLog(@"idRequest response: %@", responseBody);
        [self setUserID:[responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        [delegate linkedInDidLoginWithID:userID];
    } failure:^(BOOL success, NSError * error) {
        [self linkedInRequest:nil didFail:error];
    }];
}

- (void)profileApiCall
{
    // NOT USED
//    NSString * endpoint = @"http://api.linkedin.com/v1/people/v1/people/~:()";
    NSString *endpoint =    @"http://api.linkedin.com/v1/people/~";
    self.lhRequest = [[LinkedInHelperRequest alloc] initWithOAuthConsumer:self.storedOAuthConsumer andOAuthAccessToken:self.storedOAuthAccessToken];
    NSLog(@"DoRequestForEndpoint: %@", endpoint);
    [self.lhRequest doRequestForEndpoint:endpoint withParams:nil withBlockForSuccess:^(BOOL success, NSData * data) {
        if (success) {
            NSString *responseBody = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
            
            NSLog(@"ProfileAPICall response: %@", responseBody);
            NSDictionary *profile = [responseBody objectFromJSONString];
            
            if ( !profile )
            {
                return;
            }
            if ( [[profile objectForKey:@"status"] intValue] == 401 ) {
                NSLog(@"LinkedIn request received 401! Invalid token, must reauthenticate.");
                [delegate linkedInCredentialsNeedRefresh];
                return;
            }
            if (!userID) {
                [delegate linkedInParseSimpleProfile:profile];
                [self getId];
            }
            else {
                [delegate linkedInParseProfileInformation:profile];
            }
        }
    } failure:^(BOOL success, NSError * error) {
        NSLog(@"LinkedIn Profile call failed: error code %d %@", error.code, error.userInfo);
        if (error.code == -1001) {
            [[[UIAlertView alloc] initWithTitle:@"Time out" message:@"LinkedIn timed out! Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Time out" message:@"LinkedIn server could not be reached! Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }];

}

-(void)requestAllProfileInfoForID:(NSString*)_userID {
    NSString * endpoint = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/id=%@:(first-name,last-name,headline,industry,positions,picture-url,public-profile-url,email-address,three-current-positions,summary,connections)", _userID];
    NSLog(@"All profile request: %@", endpoint);
    self.lhRequest = [[LinkedInHelperRequest alloc] initWithOAuthConsumer:self.storedOAuthConsumer andOAuthAccessToken:self.storedOAuthAccessToken];
    NSLog(@"DoRequestForEndpoint: %@", endpoint);
    [self.lhRequest doRequestForEndpoint:endpoint withParams:nil withBlockForSuccess:^(BOOL success, NSData * data) {
        if (success) {
            NSString *responseBody = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
            
            NSLog(@"RequestProfileForID response: %@", responseBody);
            NSDictionary *profile = [responseBody objectFromJSONString];
            
            if ( !profile )
            {
                return;
            }
            if ( [[profile objectForKey:@"status"] intValue] == 401 ) {
                NSLog(@"LinkedIn request received 401! Invalid token, must reauthenticate.");
                [delegate linkedInCredentialsNeedRefresh];
                return;
            }
            [delegate linkedInParseProfileInformation:profile];
        }
    } failure:^(BOOL success, NSError * error) {
        [self linkedInRequest:nil didFail:error];
    }];
}

- (void)linkedInRequest:(OAServiceTicket *)ticket didFail:(NSError *)error
{
    NSLog(@"LinkedIn request error: %@ code: %d",[error description], error.code);
    
    if ([delegate respondsToSelector:@selector(linkedInDidFail:)]) {
        [delegate linkedInDidFail:error];
    }
}

/*
-(void) idRequest:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"idRequest response: %@", responseBody);
    [self setUserID:[responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    [delegate linkedInDidLoginWithID:userID];
    return;
}
*/
-(void)requestFriends {
    
    // send notification to start activity indicator
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseFriendsStartedUpdatingNotification object:self userInfo:nil];
    
    NSLog(@"stored auth: %@ %@", storedOAuthAccessToken, storedOAuthConsumer);
//    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections"];
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections:(first-name,last-name,headline,id,picture-url)"];
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
                didFinishSelector:@selector(requestFriendsResult:didFinish:)
                  didFailSelector:@selector(linkedInRequest:didFail:)];    
}

- (void)requestFriendsResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    // send notification to start activity indicator
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseFriendsFinishedUpdatingNotification object:self userInfo:nil];

    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"requestFriends response: %@", responseBody);
    NSDictionary *friends = [responseBody objectFromJSONString];
    [delegate linkedInParseFriends:friends];
}

-(void)requestOriginalPhotoWithBlock:(void (^)(NSString *))gotURL {
    NSString * endpoint = @"http://api.linkedin.com/v1/people/~/picture-urls::(original)";
    self.lhRequest = [[LinkedInHelperRequest alloc] initWithOAuthConsumer:self.storedOAuthConsumer andOAuthAccessToken:self.storedOAuthAccessToken];
    NSLog(@"DoRequestForEndpoint: %@", endpoint);
    [self.lhRequest doRequestForEndpoint:endpoint withParams:nil withBlockForSuccess:^(BOOL success, NSData * data) {
        if (success) {
            NSMutableDictionary * dict = [data objectFromJSONData];
            NSLog(@"URL: %@", [[dict objectForKey:@"values"] objectAtIndex:0]);
            gotURL([[dict objectForKey:@"values"] objectAtIndex:0]);
        }
    } failure:^(BOOL success, NSError * error) {
        NSLog(@"No photo found! error: %@", error);
        gotURL(nil);
    }];
}

- (IBAction)postButton_TouchUp:(UIButton *)sender
{    
//    [statusTextView resignFirstResponder];
    NSString * newStatus = @"";
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:storedOAuthConsumer
                                       token:storedOAuthAccessToken
                                    callback:nil
                           signatureProvider:nil];
    
    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[NSDictionary alloc] 
                             initWithObjectsAndKeys:
                             @"anyone",@"code",nil], @"visibility", 
                            newStatus, @"comment", nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *updateString = [update JSONString];
    
    [request setHTTPBodyWithString:updateString];
	[request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                  didFailSelector:@selector(postUpdateApiCallResult:didFail:)];    
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    // The next thing we want to do is call the network updates
//    [self networkApiCall];
    
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"%@",[error description]);
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginViewDidFinish"
                                                  object:nil];
}

#pragma mark cached login tokens
-(BOOL) loadCachedOAuth {
    NSLog(@"Loading cached OAuth!");
    // refreshes session, whatever session exists in the current device ** not the user
    OAuthLoginView * lView = [self loginView];
    [lView initLinkedInApi];
    OAToken * oatoken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"linkedin.com" prefix:@"junction"];
    if (oatoken) {
        [self setStoredOAuthAccessToken:oatoken];
        [self setStoredOAuthConsumer:[lView consumer]];
        return YES;
    }
    else {
        NSLog(@"No cached token! requesting login");
        return NO;
    }
    return NO;
}

-(void) saveCachedOAuth {
    NSLog(@"Saving cached OAuth!");
    [storedOAuthAccessToken storeInUserDefaultsWithServiceProviderName:@"linkedin.com" prefix:@"junction"];
}

-(void) clearCachedOAuth {
    self.storedOAuthAccessToken = nil;
    self.storedOAuthConsumer = nil;
	[OAToken removeFromUserDefaultsWithServiceProviderName:@"linkedin.com" prefix:@"junction"];
}

-(BOOL)isLoggedIn {
    // comment out this line to force linkedIn login
    [self loadCachedOAuth];
    
    if ([storedOAuthAccessToken isValid]) {
        NSLog(@"LinkedIn is logged in!");
        return YES;
    }
    else {
        NSLog(@"LinkedIn is not logged in!");
        return NO;
    }
}
@end
