//
//  SettingsViewController.h
//  Junction
//
//  Created by Bobby Ren on 3/1/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UISwitch * toggleVisibility;
}

-(IBAction)didToggleVisibility:(id)sender;
@end
