//
//  SideTabController.h
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SideTabController : UIViewController

@property (nonatomic, strong) IBOutlet UIView * sidebarView;
@property (nonatomic, strong) IBOutlet UIView * contentView;
//@property (nonatomic, strong) IBOutlet UIView * headerView;
@property (nonatomic, strong) NSMutableArray * viewControllers;
@property (nonatomic, strong) NSMutableArray * sidebarItems;

-(void)addController:(UIViewController*)viewController withNormalImage:(UIImage*)normalImage andHighlightedImage:(UIImage*)highlightedImage andTitle:(NSString*)title;
-(void)selectSidebarItem:(id)sender;
-(void)didSelectViewController:(int)index;

@end
