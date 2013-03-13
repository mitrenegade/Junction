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
@synthesize delegate;

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
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
    }
    else {
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoBlurURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoBlurURL]);
        if (userInfo.photoBlur)
            [photoView setImage:userInfo.photoBlur];
        [nameLabel setText:@"Name hidden"];
    }
    NSString * jobTitle = [NSString stringWithFormat:@"%@ @ %@", userInfo.position, userInfo.company];
    [self.titleLabel setText:jobTitle];
    NSString * industryTitle = [[NSString stringWithFormat:@"in %@ industry", userInfo.industry] uppercaseString];
    [self.industryLabel setText:industryTitle];
    
    [self.lookingForDetail setText:userInfo.lookingFor];
    CGSize labelSize = [self.lookingForDetail.text sizeWithFont:self.lookingForDetail.font
                                constrainedToSize:self.lookingForDetail.frame.size
                                    lineBreakMode:UILineBreakModeWordWrap];
    CGRect newframe = self.lookingForDetail.frame;
    newframe.size.width = labelSize.width;
    newframe.size.height = labelSize.height;
    [self.lookingForDetail setFrame:newframe];
    
    CGRect labelFrame = self.talkAboutTitle.frame;
    labelFrame.origin.y = newframe.origin.y + newframe.size.height + 20;
    [self.talkAboutTitle setFrame:labelFrame];
    
    [self.talkAboutDetail setText:userInfo.talkAbout];
    CGRect detailFrame = self.talkAboutDetail.frame;
    detailFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + 20;
    CGSize labelSize2 = [self.talkAboutDetail.text sizeWithFont:self.talkAboutDetail.font
                                              constrainedToSize:self.talkAboutDetail.frame.size
                                                  lineBreakMode:UILineBreakModeWordWrap];
    detailFrame.size.width = labelSize2.width;
    detailFrame.size.height = labelSize2.height;
    [self.talkAboutDetail setFrame:detailFrame];
    
    float width = self.scrollView.frame.size.width;
    float height = self.descriptionFrame.frame.origin.y + self.talkAboutDetail.frame.origin.y + self.talkAboutDetail.frame.size.height + 20;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    [self.scrollView setContentOffset:CGPointMake(0,0)];
    NSLog(@"UserProfile UpdateUserInfo done");
//    NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
}

-(void)toggleViewForConnection:(BOOL)isConnected {
    // used for preview - use only the photos stored in myUserInfo, no AWS link
    [photoView setImageURL:nil];
    if (isConnected) {
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoURL]);
        if (userInfo.photo)
            [photoView setImage:userInfo.photo];
        [nameLabel setText:userInfo.username];
    }
    else {
        [photoView setImageURL:[NSURL URLWithString:[userInfo photoBlurURL]]];
        NSLog(@"Profile photo url: %@", [userInfo photoBlurURL]);
        if (userInfo.photoBlur)
            [photoView setImage:userInfo.photoBlur];
        [nameLabel setText:@"Name hidden"];
    }
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

-(IBAction)didClickBack:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didClickClose)])
        [delegate didClickClose];
    else
        [self dismissModalViewControllerAnimated:YES];
}
@end
