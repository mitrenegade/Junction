//
//  ProximityViewController.h
//  MetWorkingLite
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

@protocol ProximityDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProximityViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet UIImageView * photoView;
@property (nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic) IBOutlet UILabel * descLabel;
@property (nonatomic) IBOutlet UITableView * tableView;

@property (nonatomic) NSMutableArray * names;
@property (nonatomic) NSMutableArray * titles;
@property (nonatomic) NSMutableArray * photos;
@property (nonatomic) NSMutableArray * distances;

@property (nonatomic) UserInfo * myUserInfo;
@property (nonatomic) id delegate;

-(void)addUser:(NSString*)name withTitle:(NSString*)title withPhoto:(UIImage*)photo atDistance:(double)distance;
@end
