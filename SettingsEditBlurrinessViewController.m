//
//  SettingsEditBlurrinessViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import "SettingsEditBlurrinessViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "UIImage+GaussianBlur.h"
#import "UIImage+Resize.h"

static AppDelegate * appDelegate;

@interface SettingsEditBlurrinessViewController ()

@end

@implementation SettingsEditBlurrinessViewController

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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIImage * headerbg = [UIImage imageNamed:@"header_bg"];
    [self.navigationController.navigationBar setBackgroundImage:headerbg forBarMetrics:UIBarMetricsDefault];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [titleView setFont:[UIFont boldSystemFontOfSize:23]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:158.0/255.0 blue:205.0/255.0 alpha:1]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    titleView.text = @"Edit Blurriness";
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    self.navigationItem.titleView = titleView;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon-back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(10, 0, 30, 30)];
    UIBarButtonItem * backbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:backbutton];

    self.view.backgroundColor = COLOR_FAINTBLUE;
    
    UserInfo * userInfo = appDelegate.myUserInfo;
    if (!userInfo.photo) {
        [appDelegate loadPhotoFromWebWithBlock:^(UIImage * image) {
            [photoView setImage:image];
        }];
    }
    [photoView setImage:userInfo.photo];
    // privacy level isnt actually saved! only the resulting image!
    /*
    privacyLevel = userInfo.privacyLevel;
    if (privacyLevel > 0) {
        [sliderBlur setValue:privacyLevel];
        [self sliderDidChangeValue:nil];
    }
     */
    [sliderBlur setValue:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sliderDidChangeValue:(id)sender {
    UISlider * slider = (UISlider*)sender;
    int newPrivacyLevel = (int) (slider.value);
    if (newPrivacyLevel == privacyLevel)
        return;
    
    UIImage * newImage;
    UserInfo * userInfo = appDelegate.myUserInfo;
    
    switch (newPrivacyLevel) {
        case 0:
            // do nothing!
            newImage = userInfo.photo;
            break;
        case 1:
            // one blur
            newImage = [userInfo.photo imageWithGaussianBlur];
            break;
        case 2:
            newImage = [[self resizeImage:userInfo.photo byScale:.5] imageWithGaussianBlur];
            break;
        case 3:
            newImage = [[[self resizeImage:userInfo.photo byScale:.25] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
        case 4:
            newImage = [[[self resizeImage:userInfo.photo byScale:.15] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
        case 5:
            newImage = [[[self resizeImage:userInfo.photo byScale:.05] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
            
        default:
            newImage = userInfo.photo;
            break;
    }
    NSLog(@"Privacy changed to level %d", newPrivacyLevel);
    userInfo.privacyLevel = newPrivacyLevel;
    
    [photoView setImage:newImage];
}

-(UIImage*)resizeImage:(UIImage*)image byScale:(float)scale {
    CGSize frame = image.size;
    CGSize target = frame;
    target.width *= scale;
    target.height *= scale;
    UIImage * newImage = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
    return newImage;
}

-(void)goBack:(id)sender {
    // save
    UserInfo * userInfo = appDelegate.myUserInfo;
    userInfo.photoBlur = photoView.image;
    [userInfo savePhotoToAWSSerial:userInfo.photo andBlur:userInfo.photoBlur withBlock:^(BOOL saved) {
        NSLog(@"Saved image at %@!", userInfo.photoURL);
        NSLog(@"Saved blur image at %@!", userInfo.photoBlurURL);
        // prevent old images for this user from showing up
        [AsyncImageView clearCacheForURL:userInfo.photoURL];
        [AsyncImageView clearCacheForURL:userInfo.photoBlurURL];

        [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:nil];
    }];
    
    // save thumbnails
    CGSize thumbSize = CGSizeMake(BROWSE_THUMB_SIZE, BROWSE_THUMB_SIZE);
    UIImage * newImageThumb = [userInfo.photo resizedImage:thumbSize interpolationQuality:kCGInterpolationHigh];
    UIImage * newBlurThumb;
    if (userInfo.photoBlur.size.width > BROWSE_THUMB_SIZE)
        newBlurThumb = [userInfo.photoBlur resizedImage:thumbSize interpolationQuality:kCGInterpolationHigh];
    else
        newBlurThumb = userInfo.photoBlur;
    [userInfo saveThumbsToAWSSerial:newImageThumb andBlur:newBlurThumb withBlock:^(BOOL finished) {
        NSLog(@"New thumbnails saved!");
    }];
    
    // dismiss
    [self.navigationController popViewControllerAnimated:YES];
}
@end
