//
//  UserProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface UserProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) UserInfo * userInfo;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * industryLabel;
@property (nonatomic, weak) IBOutlet UIView * descriptionFrame;
@property (nonatomic, strong) UITextView * descriptionView;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UILabel * friendsLabel;

@end
