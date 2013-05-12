//
//  PortraitScrollViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "AsyncImageView.h"

@protocol PortraitScrollDelegate <NSObject>

-(void)didTapPortraitWithUserInfo:(UserInfo*)tappedUserInfo;

@end

@interface PortraitScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, AsyncImageDelegate>
{
    BOOL pageControlBeingUsed;
    int currentPage;
    
//    UIImageView * chatIcon;
//    UIImageView * connectIcon;
    UIButton * chatIcon;
    UIButton * connectIcon;
}
@property (nonatomic, strong) UIImage * photo;
@property (nonatomic, strong) NSMutableArray * pages;
@property (nonatomic) UIScrollView * scrollView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UserInfo * userInfo;
@property (nonatomic, strong) UIImage * lastLoadedPortrait;
@property (nonatomic, strong) AsyncImageView * photoBG;

-(void)addUserInfo:(UserInfo *)userInfo;
-(void)reloadWithUserInfo:(UserInfo*)userInfo;

@end
