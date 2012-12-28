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
    [self.descriptionLabel setText:userInfo.summary];
    
    float width = self.view.bounds.size.width;
    float height = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(width, height)];
}

-(void)updateConnections {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isConnectedWithUser:userInfo]) {

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
