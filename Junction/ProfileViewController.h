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
#import "Constants.h"
//#import "UserDescriptionViewController.h"

@protocol ProfileDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
//@property (strong, nonatomic) UserDescriptionViewController * userDescription;
@property (nonatomic, strong) UserInfo * myUserInfo;
@property (weak, nonatomic) id delegate;
@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UILabel * industryLabel;
@property (nonatomic, strong) IBOutlet UITextView * descriptionLabel;
//@property (nonatomic) NSMutableArray * filters;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;

@end
