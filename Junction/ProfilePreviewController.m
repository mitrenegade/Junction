//
//  ProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfilePreviewController.h"
#import "UIImage+GaussianBlur.h"
#import "UIImage+Resize.h"
#import "Constants.h"

@implementation ProfilePreviewController

@synthesize delegate;
@synthesize photoView;
@synthesize myUserInfo;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionFrame;
@synthesize descriptionView;
@synthesize isViewForConnections;
@synthesize viewForConnections;
@synthesize viewForStrangers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithUserInfo:(UserInfo*)userInfo {
    self = [super initWithNibName:@"ProfilePreviewController" bundle:nil];
    if (self) {
        self.myUserInfo = userInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Preview";
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didClickNext:)];
    rightButton.tintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.navigationItem.backBarButtonItem.tintColor = [UIColor blueColor];
    [self.viewForStrangers setSelected:YES];
//    [self toggleViewForConnections:NO];
}

-(void)updateMyUserInfo {
    if (isViewForConnections) {
        [nameLabel setText:myUserInfo.username];
        if (myUserInfo.photo)
            [photoView setImage:myUserInfo.photo];
    }
    else {
        [nameLabel setText:@"Name hidden"];
        if (myUserInfo.photoBlur)
            [photoView setImage:myUserInfo.photoBlur];
    }
    
    [self.titleLabel setText:myUserInfo.headline];
    [self.industryLabel setText:myUserInfo.industry];
    
    // hack: descriptionFrame only used as an initial framer
    UIFont * descriptionFont = [UIFont systemFontOfSize:14];
    CGSize newsize = [self.myUserInfo.summary sizeWithFont:descriptionFont constrainedToSize:CGSizeMake(self.scrollView.frame.size.width, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = CGRectMake(descriptionFrame.frame.origin.x, descriptionFrame.frame.origin.y, newsize.width, newsize.height + 50);
    if (!self.descriptionView) {
        self.descriptionView = [[UITextView alloc] initWithFrame:newFrame];
        [self.scrollView addSubview:self.descriptionView];
    }
    else {
        [self.descriptionView setFrame:newFrame];
    }
//    NSLog(@"Text: %@", myUserInfo.summary);
    [self.descriptionView setText:myUserInfo.summary];
    [self.descriptionView setFont:descriptionFont];
    [self.descriptionView setScrollEnabled:NO];
    
    float width = self.scrollView.frame.size.width;
    float height = self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    //NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionFrame.frame.size.width, descriptionFrame.frame.size.height);
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
        [viewForConnections setSelected:YES];
        [viewForStrangers setSelected:NO];
        isViewForConnections = YES;
    }
    else if ((UIButton*)sender == viewForStrangers) {
        [viewForConnections setSelected:NO];
        [viewForStrangers setSelected:YES];
        isViewForConnections = NO;
    }
    [self updateMyUserInfo];
}

#pragma mark navigation

-(IBAction)didClickNext:(id)sender {
    NSLog(@"Next!");
    UIImage * newImage = myUserInfo.photo;
    UIImage * newBlur = myUserInfo.photoBlur;
    
    [myUserInfo savePhotoToAWS:newImage withBlock:^(BOOL saved) {
        NSLog(@"Saved image!");
    } andBlur:newBlur withBlock:^(BOOL saved) {
        NSLog(@"Saved blur image!");
        [delegate didFinishPreview];
    }];
}

@end
