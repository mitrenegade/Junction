//
//  LinkedInHelper.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthLoginView.h"

@protocol LinkedInHelperDelegate <NSObject>
/*
-(void)linkedInDidLoginWithUsername:(NSString*)username;
-(void)linkedInDidGetHeadline:(NSString*)headline;
-(void)linkedInDidGetEmail:(NSString*)email;
-(void)linkedInDidGetPhoto:(UIImage*)photo;
 */
-(void)linkedInDidLoginWithID:(NSString*)userID;
-(void)linkedInParseProfileInformation:(NSDictionary*)profile;
-(void)linkedInParseFriends:(id)friendsResults;
@end

@interface LinkedInHelper : NSObject

//@property (nonatomic) OAuthLoginView * oAuthLoginView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString * userID;

-(OAuthLoginView*)loginView;
-(void)requestAllProfileInfoForID:(NSString*)userID;
-(void)requestFriends;
-(void)closeLoginView;
@end
