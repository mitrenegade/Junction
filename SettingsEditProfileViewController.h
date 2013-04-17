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

@interface SettingsEditProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UITableView * tableView;
    IBOutlet UIButton * buttonPullFromLinkedIn;
    IBOutlet AsyncImageView * photoView;
    IBOutlet UILabel * labelPicture;
    IBOutlet UIButton * buttonEditBlurriness;
    IBOutlet UIButton * buttonChangePicture;
}

-(IBAction)didClickPullFromLinkedIn:(id)sender;
-(IBAction)didClickButtonEditBlurriness:(id)sender;
-(IBAction)didClickButtonChangePicture:(id)sender;
@end
