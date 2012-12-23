//
//  ProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h" // for notification constants

#define CELL_LABEL_TAG 1001

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize photoView;
@synthesize myUserInfo;
@synthesize delegate;
//@synthesize userDescription;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_me"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setMyUserInfo:[delegate getMyUserInfo]];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateMyUserInfo) 
                                                 name:kMyUserInfoDidChangeNotification 
                                               object:nil];
    
}

-(void)updateMyUserInfo {
    myUserInfo = [delegate getMyUserInfo];
    [photoView setImage:myUserInfo.photo];
    [nameLabel setText:myUserInfo.username];
    [self.titleLabel setText:myUserInfo.headline];
    [self.industryLabel setText:myUserInfo.industry];
    [self.descriptionLabel setText:myUserInfo.summary];
    
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
    [self updateMyUserInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
