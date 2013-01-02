//
//  UserProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/24/12.
//
//

#import "UserProfileViewController.h"
#import "AppDelegate.h" 
#import "UIImage+GaussianBlur.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize photoView;
@synthesize userInfo;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionFrame;
@synthesize descriptionView;

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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsSentUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnections)
                                                 name:kParseConnectionsReceivedUpdated
                                               object:nil];
}

-(void)updateUserInfo {
    NSLog(@"UserProfile UpdateUserInfo");
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
        [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
    }
    else {
        [photoView setImage:[userInfo.photo imageWithGaussianBlur]];
        [nameLabel setText:@"Name Hidden"];
    }
    [self.titleLabel setText:userInfo.headline];
    [self.industryLabel setText:userInfo.industry];
    // hack: descriptionLabel only used as an initial framer
    
    UIFont * descriptionFont = [UIFont systemFontOfSize:14];
    CGSize newsize = [userInfo.summary sizeWithFont:descriptionFont constrainedToSize:CGSizeMake(self.scrollView.frame.size.width, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = CGRectMake(descriptionFrame.frame.origin.x, descriptionFrame.frame.origin.y, newsize.width, newsize.height + 50);
    if (!self.descriptionView) {
        self.descriptionView = [[UITextView alloc] initWithFrame:newFrame];
        [self.scrollView addSubview:self.descriptionView];
    }
    else {
        [self.descriptionView setFrame:newFrame];
    }
    [self.descriptionView setText:userInfo.summary];
    [self.descriptionView setFont:descriptionFont];
    [self.descriptionView setScrollEnabled:NO];
//    [self.descriptionView setBackgroundColor:[UIColor redColor]];
    
    float width = self.scrollView.frame.size.width;
    float height = descriptionView.frame.origin.y + descriptionView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollView setContentOffset:CGPointMake(0,0)];
    NSLog(@"UserProfile UpdateUserInfo done");
//    NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
}

-(void)updateConnections {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {
#if 0
        [self.nameLabel setText:userInfo.username];
        [self.photoView setImage:userInfo.photo];
#else
        [self updateUserInfo];
#endif
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        
    }
    else if ([appDelegate isConnectRequestSentToUser:userInfo]) {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsReceivedUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsSentUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsUpdated
                                                  object:nil];
}
-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsReceivedUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsSentUpdated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kParseConnectionsUpdated
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
