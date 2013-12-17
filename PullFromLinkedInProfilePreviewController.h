//
//  PullFromLinkedInProfilePreviewController.h
//  Junction
//
//  Created by Bobby Ren on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "UserProfileViewController.h"
#import "UserInfo.h"
#import "MBProgressHUD.h"

@protocol PullFromLinkedInProfilePreviewDelegate <NSObject>

-(void)didApprovePreview;

@end

@interface PullFromLinkedInProfilePreviewController : UIViewController <UINavigationControllerDelegate, UserProfileDelegate>
{
    NSString * savedLinkedInString;
    MBProgressHUD * progress;
    IBOutlet UIButton * buttonApprove;
    IBOutlet UIButton * buttonCancel;
}
@property (nonatomic, strong) UserProfileViewController * userProfileViewController;
@property (nonatomic, weak) IBOutlet UIButton * viewForStrangers;
@property (nonatomic, weak) IBOutlet UIButton * viewForConnections;
@property (nonatomic) BOOL isViewForConnections;
@property (nonatomic, strong) UserInfo * userInfo;
@property (nonatomic, weak) IBOutlet UIView * viewForFrame;
@property (nonatomic, weak) id delegate;

-(IBAction)toggleViewForConnections:(id)sender;
-(IBAction)didClickApprove:(id)sender;
-(IBAction)didClickCancel:(id)sender;
@end
