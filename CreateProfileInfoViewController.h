//
//  CreateProfileInfoViewController.h
//  Junction
//
//  Created by Bobby Ren on 1/27/13.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

#define ROW_HEIGHT 40

@protocol CreateProfileInfoDelegate <NSObject>

-(void)didSaveProfileInfo;

@end

@interface CreateProfileInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate>

@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * inputFields;
@property (nonatomic, weak) UserInfo * userInfo;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIButton * stepButton;
-(void)populateWithUserInfo:(UserInfo*)newUserInfo;
-(IBAction)didClickNext:(id)sender;
@end
