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

#define HEADER_HEIGHT 15

@interface SettingsProfessionalInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonPullFromLinkedIn;
    UIButton * buttonAddRole;
}

-(void)didClickAddRole:(id)sender;
-(IBAction)didClickPullFromLinkedIn:(id)sender;

@end
