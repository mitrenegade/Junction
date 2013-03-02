//
//  ChatBrowserViewController
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import <UIKit/UIKit.h>

#define CB_TAG_PHOTO 1001
#define CB_TAG_NAMELABEL 1002
#define CB_TAG_TEXTLABEL 1003
#define CB_TAG_TIMELABEL 1004

@interface ChatBrowserViewController : UIViewController <UINavigationControllerDelegate, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate>
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
@property (nonatomic, weak) NSMutableDictionary * recentChats;
@property (nonatomic, strong) NSMutableArray * recentChatsArray;

#if USE_PULL_TO_REFRESH
@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL hasHeaderRow;
#endif

#if USE_PULL_TO_REFRESH
- (void)dataSourceDidFinishLoadingNewData;
#endif

@end
