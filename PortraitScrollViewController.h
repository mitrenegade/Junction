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
@property (nonatomic, strong) UIImage * photo;
@property (nonatomic, strong) NSMutableArray * pages;
@property (nonatomic) UIScrollView * scrollView;
@property (nonatomic, strong) UIPageControl * pageControl;

-(void)addUserInfo:(UserInfo *)userInfo;

@end
