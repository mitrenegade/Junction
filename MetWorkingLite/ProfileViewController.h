//
//  ProfileViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@protocol ProfileDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProfileViewController : UIViewController

@property (nonatomic) IBOutlet UIImageView * photoView;
@property (nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic) IBOutlet UILabel * descLabel;
@property (nonatomic) IBOutlet UIScrollView * scrollView;
@property (nonatomic) UserInfo * myUserInfo;
@property (nonatomic) id delegate;
@end
