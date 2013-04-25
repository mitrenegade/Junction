//
//  SettingsProfessionalInfoViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserInfo.h"
#import "LinkedInHelper.h"
#import "MBProgressHUD.h"
#import "SettingsEditRoleViewController.h"

#define HEADER_HEIGHT 15

@interface SettingsProfessionalInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, LinkedInHelperDelegate, SettingsEditRoleDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonPullFromLinkedIn;
    UIButton * buttonAddRole;
    MBProgressHUD * progress;
}

@property (nonatomic, strong) LinkedInHelper * lhHelper;
@property (nonatomic, strong) UserInfo * shellUserInfo;

-(void)didClickAddRole:(id)sender;
-(IBAction)didClickPullFromLinkedIn:(id)sender;

@end
