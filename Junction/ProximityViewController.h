//
//  ProximityViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "UserPulse.h"
#import "PortraitScrollViewController.h"
#import "OrderedUser.h"

#define HEADER_HEIGHT 30
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define PHOTO_TAG 1003
#define NUM_COLUMNS 2

enum DISTANCE_GROUPS {
    CLOSE = 0,
    ROOM = 1,
    BALLROOM = 2,
    BALLPARK = 3,
    DISTANT = 4,
    INFINITE = 5,
    MAX_DISTANCE_GROUPS
    };

@interface ProximityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PortraitScrollDelegate, PF_EGORefreshTableHeaderDelegate>
{
    PF_EGORefreshTableHeaderView *refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic) BOOL showConnectionsOnly;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSMutableDictionary * userInfos;
@property (nonatomic, strong) NSMutableArray * distanceGroupsIDSets;
@property (nonatomic, strong) NSMutableArray * distanceGroupsOrdered;

@property (nonatomic, strong) NSMutableDictionary * portraitViews;
@property (nonatomic, strong) NSMutableDictionary * portraitLoaded;
@property (nonatomic, strong) NSMutableDictionary * headerViews;

@property (weak, nonatomic) UserInfo * myUserInfo;

-(void)reloadAll;
-(IBAction)didClickSearch:(id)sender;
-(void)reloadUserPortrait:(UserInfo*)friendUserInfo withPulse:(UserPulse*)pulse;
@end
