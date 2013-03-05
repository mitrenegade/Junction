//
//  FilterViewController.h
//  Junction
//
//  Created by Bobby Ren on 3/5/13.
//
//

#import <UIKit/UIKit.h>

enum FILTER_INPUT_FIELDS {
    INPUT_FILTER_INDUSTRY = 0,
    INPUT_FILTER_COMPANY,
    INPUT_FILTER_FRIENDS
};

@interface FilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UIButton * buttonFilter;
@property (nonatomic, weak) IBOutlet UILabel * labelTitle;

@property (nonatomic, strong) NSMutableArray * viewsForCell;

-(IBAction)didClickFilter:(id)sender;
@end
