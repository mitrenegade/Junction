//
//  SettingsEditProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AsyncImageView.h"
#import "LinkedInHelper.h"
#import "UserInfo.h"
#import "PullFromLinkedInProfilePreviewController.h"
#import "MBProgressHUD.h"

@interface SettingsEditProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LinkedInHelperDelegate, PullFromLinkedInProfilePreviewDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonPullFromLinkedIn;
    IBOutlet AsyncImageView * photoView;
    IBOutlet UILabel * labelPicture;
    IBOutlet UIButton * buttonEditBlurriness;
    IBOutlet UIButton * buttonChangePicture;
    MBProgressHUD * progress;
}

@property (nonatomic, strong) LinkedInHelper * lhHelper;
@property (nonatomic, strong) UserInfo * shellUserInfo;

-(IBAction)didClickPullFromLinkedIn:(id)sender;
-(IBAction)didClickButtonEditBlurriness:(id)sender;
-(IBAction)didClickButtonChangePicture:(id)sender;
@end
