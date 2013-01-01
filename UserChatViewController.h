//
//  UserChatViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

#define MAX_ENTRIES_LOADED 25
#define TAG_PHOTO 1001
#define TAG_TEXTLABEL 1002
#define TAG_TIMELABEL 1003
#define CLASSNAME @"Chat"

@interface UserChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PF_EGORefreshTableHeaderDelegate, UITextFieldDelegate>
{
    PF_EGORefreshTableHeaderView *refreshHeaderView;
    BOOL _reloading;
}
@property (nonatomic, weak) UserInfo * userInfo;

@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * labelConnectionRequired;
@property (nonatomic, weak) IBOutlet UIButton * buttonConnect;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIView * chatView;
@property (nonatomic, weak) IBOutlet UITextField * chatInput;
@property (nonatomic, weak) IBOutlet UITextField * chatBar;

@property (nonatomic, weak) IBOutlet UIButton * buttonChat;
@property (nonatomic, strong) NSString * chatChannel;
@property (nonatomic, strong) UIImage * userPhoto;

@property (nonatomic, strong) NSMutableArray *chatData;

-(IBAction)didClickSendChat:(id)sender;
-(IBAction)didClickConnect:(id)sender;

-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;
@end
