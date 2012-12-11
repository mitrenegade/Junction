//
//  PortraitScrollViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface PortraitScrollViewController : UIViewController <UIScrollViewDelegate>
{
    BOOL pageControlBeingUsed;
    int currentPage;
}
@property (nonatomic) UIImage * photo;
@property (nonatomic) NSMutableArray * pages;
@property (nonatomic) UIScrollView * scrollView;

-(void)addUserInfo:(UserInfo *)userInfo;

@end
