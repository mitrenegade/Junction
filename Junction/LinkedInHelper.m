    //
//  LinkedInHelper.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkedInHelper.h"
#import "AppDelegate.h"

static OAuthLoginView * sharedOAuthLoginView;

@implementation LinkedInHelper

//@synthesize oAuthLoginView;
@synthesize delegate;
@synthesize userID;
@synthesize storedOAuthConsumer;
@synthesize storedOAuthAccessToken;

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    
    // store and cache oauth tokens
    [self setStoredOAuthConsumer:sharedOAuthLoginView.consumer];
    [self setStoredOAuthAccessToken:sharedOAuthLoginView.accessToken];
    [self saveCachedOAuth];
    
    NSLog(@"stored auth: %@ %@", storedOAuthAccessToken, storedOAuthConsumer);    
    
    [self profileApiCall];
}

-(void)closeLoginView {
    if (sharedOAuthLoginView)
        [sharedOAuthLoginView.view removeFromSuperview];
}

- (void)profileApiCall
{
    NSLog(@"Making linkedIn request: profileAPICall");
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
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
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(profileApiCallResult:didFail:)];    
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
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

-(void)profileApiCallResult:(OAServiceTicket*)ticket didFail:(NSError*)error {
    NSLog(@"LinkedIn Profile call failed: error code %d %@", error.code, error.userInfo);
    if (error.code == -1001) {
        [[[UIAlertView alloc] initWithTitle:@"Time out" message:@"LinkedIn timed out! Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Time out" message:@"LinkedIn server could not be reached! Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)linkedInRequest:(OAServiceTicket *)ticket didFail:(NSError *)error
{
    NSLog(@"LinkedIn request error: %@ code: %d ticket: %@",[error description], error.code, ticket.response.description);
    
    if (error.code == -1001) {
        // timeout
        NSLog(@"Request timed out!");
    }
}

-(void)getId {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/id"];
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
                didFinishSelector:@selector(idRequest:didFinish:)
                  didFailSelector:@selector(linkedInRequest:didFail:)];  
}

-(void) idRequest:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"idRequest response: %@", responseBody);
    [self setUserID:[responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    [delegate linkedInDidLoginWithID:userID];
    return;
}

-(void)requestAllProfileInfoForID:(NSString*)_userID {
//    NSString * requestString = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/id=%@:(first-name,last-name,location:(name),industry,summary,picture-url,email-address,specialties,three-current-positions)", _userID];
    NSString * requestString = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/id=%@:(first-name,last-name,industry,positions,picture-url,public-profile-url,email-address,three-current-positions,summary,connections)", _userID];
    NSLog(@"All profile request: %@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
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
                didFinishSelector:@selector(profileApiCallResult:didFinish:)
                  didFailSelector:@selector(linkedInRequest:didFail:)];  
}

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
/*
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
*/

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
