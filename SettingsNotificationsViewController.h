//
//  SettingsNotificationsViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#define HEADER_HEIGHT 15

@interface SettingsNotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UISwitch * toggleNotifyReceive;
    IBOutlet UISwitch * toggleNotifyAccept;
    IBOutlet UISwitch * toggleNotifyFollowup;
}

-(IBAction)didToggle:(id)sender;

@end
