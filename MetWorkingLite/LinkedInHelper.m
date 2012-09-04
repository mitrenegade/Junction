//
//  LinkedInHelper.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkedInHelper.h"
#import "OAuthLoginView.h"

@implementation LinkedInHelper

@synthesize oAuthLoginView;
@synthesize delegate;

-(OAuthLoginView*) loginView 
{    
    oAuthLoginView = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
    
    // register to be told when the login is finished
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginViewDidFinish:) 
                                                 name:@"loginViewDidFinish" 
                                               object:oAuthLoginView];
    
    return oAuthLoginView;
}


-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // We're going to do these calls serially just for easy code reading.
    // They can be done asynchronously
    // Get the profile, then the network updates
    [self profileApiCall];
	
}

- (void)profileApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:oAuthLoginView.consumer
                                       token:oAuthLoginView.accessToken
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
    NSString * name = [[NSString alloc] initWithFormat:@"%@ %@",
                       [profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]];
    NSString * headline = [profile objectForKey:@"headline"];
    NSLog(@"Name: %@ headline: %@", name, headline);
    
    // The next thing we want to do is call the network updates
    //[self networkApiCall];
    
    //delegate didLoginWithUser
    [delegate linkedInDidLoginWithUsername:name];
    [delegate linkedInDidGetHeadline:headline];
    
    [self getEmail];
    [self getPhoto];
}

- (void)profileApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"%@",[error description]);
}

-(void)getEmail {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/email-address"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:oAuthLoginView.consumer
                                       token:oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(emailRequest:didFinish:)
                  didFailSelector:@selector(emailRequest:didFail:)];  
}

-(void) emailRequest:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"email response: %@", responseBody);
    
    NSString * email = [responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [delegate linkedInDidGetEmail:email];
    return;
}

- (void)emailRequest:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"email failed: %@",[error description]);
}


-(void)getPhoto {
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/picture-url"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:oAuthLoginView.consumer
                                       token:oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(photoRequest:didFinish:)
                  didFailSelector:@selector(photoRequest:didFail:)];  
}

-(void) photoRequest:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"photoRequest response: %@", responseBody);
    NSString * url = [responseBody stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [delegate linkedInDidGetPhoto:image];
    return;
}

- (void)photoRequest:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"photoRequest failed: %@",[error description]);
}






- (IBAction)postButton_TouchUp:(UIButton *)sender
{    
//    [statusTextView resignFirstResponder];
    NSString * newStatus = @"";
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
    OAMutableURLRequest *request = 
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:oAuthLoginView.consumer
                                       token:oAuthLoginView.accessToken
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
