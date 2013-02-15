//
//  SideTabController.m
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import "SideTabController.h"
#import "AppDelegate.h"
#import "UIAlertView+MKBlockAdditions.h"

@interface SideTabController ()

@end

@implementation SideTabController

@synthesize sidebarView, contentView;
//@synthesize headerView;
@synthesize viewControllers, sidebarItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewControllers = [[NSMutableArray alloc] init];
        sidebarItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    /*
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.alpha = 0.7f;
    [self.navigationController.navigationBar setTranslucent:YES];
     */
    CGRect frame = sidebarView.frame;
    frame.size.width = SIDEBAR_WIDTH;
    [sidebarView setFrame:frame];
    
    for (UIButton * button in sidebarItems)
        [sidebarView addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addController:(UIViewController*)viewController withNormalImage:(UIImage*)normalImage andHighlightedImage:(UIImage*)highlightedImage andTitle:(NSString*)title {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectSidebarItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTag:[sidebarItems count]];
    int dim = SIDEBAR_WIDTH;
    button.frame = CGRectMake(0, (dim+20)*button.tag, dim, dim+20);
    
    UILabel * buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, dim, dim, 20)];
    [buttonTitle setText:title];
    [buttonTitle setBackgroundColor:[UIColor clearColor]];
    [buttonTitle setFont:[UIFont systemFontOfSize:10]];
    [buttonTitle setTextColor:[UIColor whiteColor]];
    [buttonTitle setTextAlignment:NSTextAlignmentCenter];
    [buttonTitle setAdjustsFontSizeToFitWidth:YES];
    [button addSubview:buttonTitle];

    [sidebarItems addObject:button];
    [viewControllers addObject:viewController];
}

-(void)selectSidebarItem:(id)sender {
    UIButton * button = (UIButton*)sender;
    int index = button.tag;
    if (index > [viewControllers count])
        return;
    [self didSelectViewController:index];
}

-(void)didSelectViewController:(int)index {
    UIViewController * controller = [viewControllers objectAtIndex:index];
//    if ([controller respondsToSelector:@selector(headerView)]) {
//        UIView * header = controller.headerView;
//    }
    for (UIView * subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [self.contentView addSubview:[controller view]];
    CGRect frame = self.contentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [controller.view setFrame:frame];
    NSLog(@"ContentView: %f %f controller view: %f %f", contentView.frame.size.width, contentView.frame.size.height, controller.view.frame.size.width, controller.view.frame.size.height);
}

-(IBAction)didClickSettings:(id)sender {
    [UIAlertView alertViewWithTitle:@"Log out?" message:@"Do you want to log out?" cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObject:@"Logout"] onDismiss:^(int buttonIndex) {
        // for now log out
        AppDelegate * appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [appDelegate didLogout];
    } onCancel:^{
        return;
    }];
}
@end
