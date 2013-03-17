//
//  CreateProfilePreviewController.h
//  Junction
//
//  Created by Bobby Ren on 3/13/13.
//
//

#import <UIKit/UIKit.h>
#import "UserProfileViewController.h"
#import "UserInfo.h"
#import "MBProgressHUD.h"

@protocol ProfilePreviewDelegate <NSObject>

-(void)didFinishPreview;

@end

@interface CreateProfilePreviewController : UIViewController <UINavigationControllerDelegate, UserProfileDelegate>
{
    NSString * savedLinkedInString;
    MBProgressHUD * progress;
}
@property (nonatomic, strong) UserProfileViewController * userProfileViewController;
@property (nonatomic, weak) IBOutlet UIButton * viewForStrangers;
@property (nonatomic, weak) IBOutlet UIButton * viewForConnections;
@property (nonatomic) BOOL isViewForConnections;
@property (nonatomic, strong) UserInfo * userInfo;
@property (nonatomic, weak) IBOutlet UIView * viewForFrame;
@property (nonatomic, weak) id delegate;

-(IBAction)toggleViewForConnections:(id)sender;
@end
