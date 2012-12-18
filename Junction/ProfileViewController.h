//
//  ProfileViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "InputViewController.h"

@protocol ProfileDelegate <NSObject>

-(UserInfo*)getMyUserInfo;

@end

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InputViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView * photoView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UILabel * descLabel;
@property (weak, nonatomic) UserInfo * myUserInfo;
@property (weak, nonatomic) id delegate;
@property (nonatomic) NSMutableArray * filters;

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@end
