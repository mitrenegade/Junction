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
#define HEADER_HEIGHT 15
enum PROFILE_INPUT_FIELDS {
    INPUT_NAME = 0,
    INPUT_EMAIL = 1,
    INPUT_LOOKINGFOR = 2,
    INPUT_TALKABOUT = 3,
    //INPUT_ROLE = 2,
    //INPUT_COMPANY = 3,
    //INPUT_INDUSTRY = 4,
    INPUT_MAX
    };

@protocol CreateProfileInfoDelegate <NSObject>

-(void)didSaveProfileInfo;

@end

@interface CreateProfileInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    BOOL stopResponders;
}

@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * inputFields;
@property (nonatomic, strong) NSMutableArray * viewsForCell;
@property (nonatomic, strong) NSMutableArray * viewsForHeader;
@property (nonatomic, weak) UserInfo * userInfo;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIButton * stepButton;

@property (nonatomic, strong) UILabel * privateLabel;
@property (nonatomic, strong) UISlider * privateSlider;

@property (nonatomic, strong) UILabel * lookingForCount;
@property (nonatomic, strong) UILabel * talkAboutCount;
@property (nonatomic, strong) NSString * lookingForLastText;
@property (nonatomic, strong) NSString * talkAboutLastText;

-(void)populateWithUserInfo:(UserInfo*)newUserInfo;
-(IBAction)didClickNext:(id)sender;
@end
