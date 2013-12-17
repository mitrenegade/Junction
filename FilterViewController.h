//
//  FilterViewController.h
//  Junction
//
//  Created by Bobby Ren on 3/5/13.
//
//

#import <UIKit/UIKit.h>
#import "IndustryFilterTableViewController.h"

enum FILTER_INPUT_FIELDS {
    INPUT_FILTER_POSITION = 0,
    INPUT_FILTER_COMPANY,
    INPUT_FILTER_INDUSTRY,
    INPUT_FILTER_FRIENDS
};

#define FILTER_ROW_HEIGHT 35

@protocol FilterDelegate <NSObject>

-(int)doFilter;
-(void)closeFilter;

@end

@interface FilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IndustryFilterDelegate, UITextFieldDelegate>
{
    IBOutlet UIButton * buttonClearPosition;
    IBOutlet UIButton * buttonClearCompany;
    
    IBOutlet UIView * noResultsView;
    IBOutlet UIButton * noResultsButton;
    IBOutlet UILabel * noResultsLabel;
}
@property (nonatomic, weak) id delegate;

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIButton * buttonFilter;
@property (nonatomic, weak) IBOutlet UILabel * labelTitle;

@property (nonatomic, strong) NSMutableArray * viewsForCell;

@property (nonatomic, strong) NSString * industryFilter;
@property (nonatomic, strong) UITextField * industryField;
@property (nonatomic, strong) NSString * companyFilter;
@property (nonatomic, strong) UITextField * companyField;
@property (nonatomic, strong) NSString * positionFilter;
@property (nonatomic, strong) UITextField * positionField;
@property (nonatomic, assign) BOOL friendsFilter;
@property (nonatomic, strong) UISwitch * friendsSwitch;

-(IBAction)didClickFilter:(id)sender;
-(IBAction)didClickClear:(id)sender;
-(IBAction)didClickClearAll:(id)sender;

-(void)showEmptyResultsMessage;
-(IBAction)didClickEmptyResultsButton:(id)sender;
@end
