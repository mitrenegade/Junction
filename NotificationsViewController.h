//
//  NotificationsViewController.h
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "JunctionNotification.h"

#define TAG_PHOTO 1001
#define TAG_TYPELABEL 1002
#define TAG_INFOLABEL 1003
#define TAG_LASTROW 1004
@interface NotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PF_EGORefreshTableHeaderDelegate>
{
    PF_EGORefreshTableHeaderView *refreshHeaderView;
    BOOL _reloading;
}
@property (nonatomic) IBOutlet UITableView * tableView;
//@property (nonatomic, strong) NSMutableArray * users;
@property (nonatomic, strong) NSMutableArray * notifications;
@property (nonatomic, strong) NSMutableArray * connectRequestUserInfos;

-(NSMutableArray*) findNotificationsOfType:(NSString*)notificationType fromSender:(UserInfo*)sender;
-(void)refreshNotifications;

@end
