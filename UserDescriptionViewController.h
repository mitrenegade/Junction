//
//  UserDescriptionViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
@interface UserDescriptionViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong) IBOutlet UILabel * industryLabel;
@property (nonatomic, strong) IBOutlet UITextView * descriptionLabel;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * industry;
@property (nonatomic, strong) NSString * description;
//@property (nonatomic, weak) UserInfo * userInfo;

-(void)refreshDescription;

@end
