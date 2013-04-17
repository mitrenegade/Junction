//
//  TutorialViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface TutorialViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray * viewControllers;
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIPageControl * pageControl;
}

@property (nonatomic, assign) BOOL forceDone;
@end
