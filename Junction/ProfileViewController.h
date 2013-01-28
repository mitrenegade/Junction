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

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet AsyncImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) UserInfo * myUserInfo;
//@property (weak, nonatomic) id delegate;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * industryLabel;
@property (nonatomic, weak) IBOutlet UIView * descriptionFrame;
@property (nonatomic, strong) UITextView * descriptionView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;

@property (nonatomic, weak) IBOutlet UIButton * viewForStrangers;
@property (nonatomic, weak) IBOutlet UIButton * viewForConnections;
@property (nonatomic) BOOL isViewForConnections;

@property (nonatomic) IBOutlet UISlider * slider;
-(IBAction)toggleViewForConnections:(id)sender;
-(IBAction)sliderDidChange:(id)sender;
@end
