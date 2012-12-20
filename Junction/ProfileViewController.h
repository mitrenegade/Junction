//
//  ProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "InputViewController.h"
#import "UserDescriptionViewController.h"

@protocol ProfileDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (strong, nonatomic) UserDescriptionViewController * userDescription;
@property (nonatomic, strong) UserInfo * myUserInfo;
@property (weak, nonatomic) id delegate;
//@property (nonatomic) NSMutableArray * filters;

@end
