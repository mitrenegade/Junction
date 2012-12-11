//
//  PortraitScrollView.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/27/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface PortraitScrollView : UIScrollView

@property (nonatomic) UIImage * photo;
@property (nonatomic) NSMutableArray * pages;

-(void)addUserInfo:(UserInfo *)userInfo;

@end
