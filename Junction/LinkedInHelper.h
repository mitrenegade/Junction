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
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) OAConsumer * storedOAuthConsumer;
@property (nonatomic, strong) OAToken * storedOAuthAccessToken;

-(BOOL)isLoggedIn;
-(OAuthLoginView*)loginView;
-(void)requestAllProfileInfoForID:(NSString*)userID;
-(void)requestFriends;
-(void)closeLoginView;

-(void)profileApiCall;
-(BOOL) loadCachedOAuth;
@end
