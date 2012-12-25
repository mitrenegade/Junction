//
//  UserProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "UserProfileViewController.h"
#import "AppDelegate.h" 

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize photoView;
@synthesize userInfo;
//@synthesize delegate;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // must set userinfo before controller is displayed
    [self updateUserInfo];
}

-(void)updateUserInfo {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setUserInfo:[appDelegate myUserInfo]];
    [photoView setImage:userInfo.photo];
    [nameLabel setText:userInfo.username];
    [self.titleLabel setText:userInfo.headline];
    [self.industryLabel setText:userInfo.industry];
    [self.descriptionLabel setText:userInfo.summary];
    
    float width = self.view.bounds.size.width;
    float height = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(width, height)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMyUserInfoDidChangeNotification
                                                  object:nil];
}
-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMyUserInfoDidChangeNotification
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
