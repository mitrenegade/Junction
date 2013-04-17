//
//  SettingsEditRoleViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserInfo.h"

@interface SettingsEditRoleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITableView * tableView;

}
@end
