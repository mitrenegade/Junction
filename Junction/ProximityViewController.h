//
//  ProximityViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

#define ROW_HEIGHT 60
#define TOP_LABEL_TAG 1001
#define BOTTOM_LABEL_TAG 1002
#define PHOTO_TAG 1003

enum DISTANCE_GROUPS {
    CLOSE = 0,
    ROOM = 1,
    BALLROOM = 2,
    BALLPARK = 3,
    DISTANT = 4,
    MAX_DISTANCE_GROUPS
    };
@protocol ProximityDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProximityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UILabel * descLabel;
@property (weak, nonatomic) IBOutlet UITableView * tableView;
/*
@property (nonatomic) NSMutableArray * names;
@property (nonatomic) NSMutableArray * titles;
@property (nonatomic) NSMutableArray * photos;
@property (nonatomic) NSMutableArray * distances;
*/
@property (nonatomic) NSMutableDictionary * userInfos;
@property (nonatomic) NSMutableArray * distanceGroups;

@property (weak, nonatomic) UserInfo * myUserInfo;
@property (weak, nonatomic) id delegate;

-(void)addUser:(NSString*)userID withName:(NSString*)name withHeadline:(NSString*)headline withPhoto:(UIImage*)photo atDistance:(double)distance;
@end
