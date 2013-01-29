//
//  ProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "Constants.h"
#import "AsyncImageView.h"

@protocol ProfilePreviewDelegate <NSObject>

-(void)didFinishPreview;

@end

@interface ProfilePreviewController : UIViewController

@property (nonatomic, weak) id delegate;

@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) UserInfo * myUserInfo;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * industryLabel;
@property (nonatomic, weak) IBOutlet UIView * descriptionFrame;
@property (nonatomic, strong) UITextView * descriptionView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;

@property (nonatomic, weak) IBOutlet UIButton * viewForStrangers;
@property (nonatomic, weak) IBOutlet UIButton * viewForConnections;
@property (nonatomic) BOOL isViewForConnections;

-(IBAction)toggleViewForConnections:(id)sender;
-(id)initWithUserInfo:(UserInfo*)userInfo;
@end
