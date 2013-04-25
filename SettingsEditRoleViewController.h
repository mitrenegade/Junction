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
#import "IndustryFilterTableViewController.h"

@protocol SettingsEditRoleDelegate <NSObject>

-(void)didSaveRoleAtIndex:(int)index withPosition:(NSString*)newPosition withCompany:(NSString*)newCompany withIndustry:(NSString*)newIndustry;

@end

@interface SettingsEditRoleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, IndustryFilterDelegate, UITextFieldDelegate>
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UITextField * inputPosition;
    IBOutlet UITextField * inputCompany;
    IBOutlet UITextField * inputIndustry;
    
    IBOutlet UIButton * buttonSave;
    
//    UIPickerView * pickerIndustry;
}

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) int roleIndex;
@property (nonatomic, strong) NSString * position;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * industry;

-(IBAction)didClickSave:(id)sender;
@end
