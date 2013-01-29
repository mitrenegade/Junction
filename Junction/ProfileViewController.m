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
#import "UIImage+Resize.h"
#import "Constants.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize photoView;
@synthesize myUserInfo;
@synthesize scrollView;
@synthesize nameLabel;
@synthesize titleLabel, industryLabel, descriptionFrame;
@synthesize descriptionView;

@synthesize isViewForConnections;
@synthesize viewForConnections;
@synthesize viewForStrangers;
@synthesize slider;

@synthesize isPreview;
@synthesize delegate;

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
    if (!isPreview) {
        AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [self setMyUserInfo:[appDelegate myUserInfo]];
    }
    else {
        self.navigationItem.title = @"Preview";
        
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didClickNext:)];
        rightButton.tintColor = [UIColor orangeColor];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        self.navigationItem.backBarButtonItem.tintColor = [UIColor blueColor];
    }
    [self.viewForStrangers setSelected:YES];
}

-(void)updateMyUserInfo {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!isPreview)
        [self setMyUserInfo:[appDelegate myUserInfo]];
    
    [slider setHidden:YES];
    if (isViewForConnections) {
        [nameLabel setText:myUserInfo.username];
        if (!isPreview)
            [photoView setImageURL:[NSURL URLWithString:[myUserInfo photoURL]]];
        NSLog(@"Profile photo url: %@", [myUserInfo photoURL]);
        if (myUserInfo.photo)
            [photoView setImage:myUserInfo.photo];
    }
    else {
        [nameLabel setText:@"Name hidden"];
        if (!isPreview)
            [photoView setImageURL:[NSURL URLWithString:[myUserInfo photoBlurURL]]];
        NSLog(@"Profile photo url: %@", [myUserInfo photoBlurURL]);
        if (myUserInfo.photoBlur)
            [photoView setImage:myUserInfo.photoBlur];
#if USE_SLIDER_IN_PROFILE
        if (!isPreview) {
            [slider setHidden:NO];
            [slider setValue:myUserInfo.privacyLevel];
        }
#endif
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
//    [self.descriptionView setBackgroundColor:[UIColor redColor]];
    
    float width = self.scrollView.frame.size.width;
    float height = self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width, height)];
    //NSLog(@"Scroll contentwidth: %f height: %f descriptionLabel size: %f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height, descriptionFrame.frame.size.width, descriptionFrame.frame.size.height);
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

-(void)sliderDidChange:(id)sender {
#if USE_SLIDER_IN_PROFILE
    UISlider * slider = (UISlider*)sender;
    int newPrivacyLevel = (int) (slider.value);
    if (newPrivacyLevel == myUserInfo.privacyLevel)
        return;
    
    UIImage * newImage;
    
    switch (newPrivacyLevel) {
        case 0:
            // do nothing!
            newImage = myUserInfo.photo;
            break;
        case 1:
            // one blur
            newImage = [myUserInfo.photo imageWithGaussianBlur];
            break;
        case 2:
            newImage = [[self resizeImage:myUserInfo.photo byScale:.5] imageWithGaussianBlur];
            break;
        case 3:
            newImage = [[[self resizeImage:myUserInfo.photo byScale:.5] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
        case 4:
            newImage = [[self resizeImage:myUserInfo.photo byScale:.25] imageWithGaussianBlur];
            break;
        case 5:
            newImage = [[[self resizeImage:myUserInfo.photo byScale:.25] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
            
        default:
            newImage = myUserInfo.photo;
            break;
    }
    // temporarily set myUserInfo to this stuff before uploading to amazon
    myUserInfo.photoBlurURL = nil;
    myUserInfo.photoBlur = newImage;
    
    NSLog(@"Privacy changed to level %d", newPrivacyLevel);
    myUserInfo.privacyLevel = newPrivacyLevel;

    [myUserInfo savePhotoToAWS:nil withBlock:^(BOOL saved) {} andBlur:newImage withBlock:^(BOOL saved) {
        // force profile to update blurred image
        [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:self userInfo:nil];
    }];
    
    [self updateMyUserInfo];
#endif
}

-(UIImage*)resizeImage:(UIImage*)image byScale:(float)scale {
    CGSize frame = image.size;
    CGSize target = frame;
    target.width *= scale;
    target.height *= scale;
    UIImage * newImage = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
    return newImage;
}

#pragma mark navigator for preview mode
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
