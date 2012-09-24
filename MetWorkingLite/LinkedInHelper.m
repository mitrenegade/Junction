//
//  LinkedInHelper.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkedInHelper.h"
#import "OAuthLoginView.h"

static OAuthLoginView * sharedOAuthLoginView;

@implementation LinkedInHelper

//@synthesize oAuthLoginView;
@synthesize delegate;
@synthesize userID;

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
    [self profileApiCall];
	
}

-(void)closeLoginView {
    if (sharedOAuthLoginView)
        [sharedOAuthLoginView.view removeFromSuperview];
}

- (void)profileApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:sharedOAuthLoginView.consumer
                                       token:sharedOAuthLoginView.accessToken
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
    if (!userID) {
        [self getId];
    }
    else {
        [delegate linkedInParseProfileInformation:profile];
    }
}

- (void)linkedInRequest:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"%@",[error description]);
}

-(void)getId {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/id"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:sharedOAuthLoginView.consumer
                                       token:sharedOAuthLoginView.accessToken
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
    NSString * requestString = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/id=%@:(first-name,last-name,location:(name),industry,summary,picture-url,email-address,specialties,three-current-positions)", _userID];
    NSLog(@"All profile request: %@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:sharedOAuthLoginView.consumer
                                       token:sharedOAuthLoginView.accessToken
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
//    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections"];
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/connections:(first-name,last-name,headline,id,picture-url)"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:sharedOAuthLoginView.consumer
                                       token:sharedOAuthLoginView.accessToken
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
                                    consumer:sharedOAuthLoginView.consumer
                                       token:sharedOAuthLoginView.accessToken
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
@end
