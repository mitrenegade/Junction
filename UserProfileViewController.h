//
//  UserProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "AsyncImageView.h"

@protocol UserProfileDelegate <NSObject>

@optional
-(void)didClickClose;

@end

@interface UserProfileViewController : UIViewController {
    BOOL isOwnProfile;
}

@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) IBOutlet AsyncImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) UserInfo * userInfo;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * industryLabel;
@property (nonatomic, weak) IBOutlet UIView * descriptionFrame;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UILabel * friendsLabel;

@property (nonatomic, weak) IBOutlet UILabel * lookingForTitle;
@property (nonatomic, weak) IBOutlet UILabel * lookingForDetail;
@property (nonatomic, weak) IBOutlet UILabel * talkAboutTitle;
@property (nonatomic, weak) IBOutlet UILabel * talkAboutDetail;

@property (nonatomic, weak) IBOutlet UIButton * buttonConnect;
@property (nonatomic, weak) IBOutlet UIButton * buttonBlock;
@property (nonatomic, weak) IBOutlet UIButton * buttonChat;
@property (nonatomic, weak) IBOutlet UIButton * buttonIgnore;

-(IBAction)didClickBack:(id)sender;
-(IBAction)didClickConnect:(id)sender;
-(IBAction)didClickBlock:(id)sender;
-(IBAction)didClickChat:(id)sender;
-(IBAction)didClickIgnore:(id)sender;
-(void)toggleViewForConnection:(BOOL)isConnected;
-(void)toggleInteraction:(BOOL)canInteract;
@end
