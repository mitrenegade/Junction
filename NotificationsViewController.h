//
//  NotificationsViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
#if USE_PULL_TO_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
    int numColumns;
    int borderWidth;
    int columnPadding;
    int columnWidth;
    int columnHeight;
#endif
}
@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * users;
@property (nonatomic, strong) NSMutableArray * messages;

#if USE_PULL_TO_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL hasHeaderRow;
#endif

#if USE_PULL_TO_REFRESH
- (void)dataSourceDidFinishLoadingNewData;
#endif

@end
