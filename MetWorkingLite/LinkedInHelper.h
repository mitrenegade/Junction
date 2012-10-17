//
//  LinkedInHelper.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#import "OAuthLoginView.h"

@protocol LinkedInHelperDelegate <NSObject>
-(void)linkedInDidLoginWithID:(NSString*)userID;
-(void)linkedInParseProfileInformation:(NSDictionary*)profile;
-(void)linkedInParseSimpleProfile:(NSDictionary*)profile;
-(void)linkedInParseFriends:(id)friendsResults;
@end

@interface LinkedInHelper : NSObject

//@property (nonatomic) OAuthLoginView * oAuthLoginView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) OAConsumer * storedOAuthConsumer;
@property (nonatomic, retain) OAToken * storedOAuthAccessToken;

-(BOOL)isLoggedIn;
-(OAuthLoginView*)loginView;
-(void)requestAllProfileInfoForID:(NSString*)userID;
-(void)requestFriends;
-(void)closeLoginView;

-(void)profileApiCall;
-(BOOL) loadCachedOAuth;
@end
