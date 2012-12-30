//
//  ProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h" // for notification constants
#import "UIImage+GaussianBlur.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize photoView;
@synthesize myUserInfo;
//@synthesize delegate;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionLabel;
@synthesize descriptionView;

@synthesize isViewForConnections;
@synthesize viewForConnections;
@synthesize viewForStrangers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_me"]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMyUserInfo)
                                                     name:kMyUserInfoDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setMyUserInfo:[appDelegate myUserInfo]];
    //[self updateMyUserInfo];
}

-(void)updateMyUserInfo {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self setMyUserInfo:[appDelegate myUserInfo]];
    if (isViewForConnections) {
        [photoView setImage:myUserInfo.photo];
    }
    else {
        [photoView setImage:[myUserInfo.photo imageWithGaussianBlur]];
    }
    [nameLabel setText:myUserInfo.username];
    [self.titleLabel setText:myUserInfo.headline];
    [self.industryLabel setText:myUserInfo.industry];
    
    // hack: descriptionLabel only used as an initial framer
    CGSize newsize = [self.myUserInfo.summary sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.scrollView.frame.size.width, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y, newsize.width, newsize.height + 50);
    if (!self.descriptionView) {
        self.descriptionView = [[UITextView alloc] initWithFrame:newFrame];
        [self.scrollView addSubview:self.descriptionView];
    }
    else {
        [self.descriptionView setFrame:newFrame];
    }
//    NSLog(@"Text: %@", myUserInfo.summary);
    [self.descriptionView setText:myUserInfo.summary];
    [self.descriptionView setFont:self.descriptionLabel.font];
    [self.descriptionView setScrollEnabled:NO];
//    [self.descriptionView setBackgroundColor:[UIColor redColor]];
    
    float width = self.scrollView.frame.size.width;
    float height = self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
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

-(IBAction)toggleViewForConnections:(id)sender {
    if ((UIButton*)sender == viewForConnections) {
        isViewForConnections = YES;
    }
    else if ((UIButton*)sender == viewForStrangers) {
        isViewForConnections = NO;
    }
    [self updateMyUserInfo];
}

@end
