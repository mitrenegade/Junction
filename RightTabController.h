//
//  RightTabController.h
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserInfo.h"

#import "UserProfileViewController.h"
#import "UserChatViewController.h"
#import "UserShareViewController.h"
#import "MKAdditions/UIAlertView+MKBlockAdditions.h"

//#define FIRST_BUTTON_OFFSET 60

@interface RightTabController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView * sidebarView;
@property (nonatomic, strong) IBOutlet UIView * contentView;
//@property (nonatomic, strong) IBOutlet UIView * headerView;
@property (nonatomic, strong) NSMutableArray * viewControllers;
@property (nonatomic, strong) NSMutableArray * sidebarItems;

@property (nonatomic, strong) UserProfileViewController * profileController;
@property (nonatomic, strong) UserChatViewController * chatController;
@property (nonatomic, strong) UserShareViewController * shareController;

@property (nonatomic, weak) IBOutlet UIButton * buttonConnect;
@property (nonatomic, weak) IBOutlet UILabel * labelConnect;
@property (nonatomic, weak) IBOutlet UIButton * backButton;
@property (nonatomic, weak) UserInfo * userInfo;

@property (nonatomic, strong) UIButton * buttonBlock;
@property (nonatomic, strong) UILabel * labelBlock;

-(IBAction)didClickConnect:(id)sender;
-(IBAction)didClickBlock:(id)sender;

-(void)addController:(UIViewController*)viewController withNormalImage:(UIImage*)normalImage andHighlightedImage:(UIImage*)highlightedImage andTitle:(NSString*)title;
-(void)selectSidebarItem:(id)sender;
-(void)didSelectViewController:(int)index;
//-(void)addDefaultControllers;
@end
