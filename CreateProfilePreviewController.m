//
//  CreateProfilePreviewController.m
//  Junction
//
//  Created by Bobby Ren on 3/13/13.
//
//

#import "CreateProfilePreviewController.h"
#import "AppDelegate.h"

@interface CreateProfilePreviewController ()

@end

static AppDelegate * appDelegate;

@implementation CreateProfilePreviewController

@synthesize viewForConnections, viewForFrame, viewForStrangers;
@synthesize isViewForConnections;
@synthesize userProfileViewController;
@synthesize userInfo;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.viewForStrangers setSelected:YES];
    
    self.userProfileViewController = [[UserProfileViewController alloc] init];
    [self.userProfileViewController setUserInfo:appDelegate.myUserInfo];
    [self.userProfileViewController setDelegate:self];
    
    [self.userProfileViewController setUserInfo:userInfo];
    [self.view addSubview:self.userProfileViewController.view];
    [self.userProfileViewController.view setFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60)];
    [self toggleViewForConnections:viewForStrangers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)toggleViewForConnections:(id)sender {
    if ((UIButton*)sender == viewForConnections) {
        [viewForConnections setSelected:YES];
        [viewForStrangers setSelected:NO];
        isViewForConnections = YES;
        [self.userProfileViewController toggleViewForConnection:isViewForConnections];
    }
    else if ((UIButton*)sender == viewForStrangers) {
        [viewForConnections setSelected:NO];
        [viewForStrangers setSelected:YES];
        isViewForConnections = NO;
        [self.userProfileViewController toggleViewForConnection:isViewForConnections];
    }
}

-(IBAction)didClickPhoto:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)didClickSaveProfile:(id)sender {
    NSLog(@"Next!");
    UIImage * newImage = userInfo.photo;
    UIImage * newBlur = userInfo.photoBlur;
    
    [userInfo savePhotoToAWS:newImage withBlock:^(BOOL saved) {
        NSLog(@"Saved image!");
    } andBlur:newBlur withBlock:^(BOOL saved) {
        NSLog(@"Saved blur image!");
        [delegate didFinishPreview];
    }];
}

#pragma mark UserProfileDelegate
-(void)didClickClose {
    // do nothing
}
@end