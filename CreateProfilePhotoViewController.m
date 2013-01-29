//
//  CreateProfilePhotoViewController.m
//  Junction
//
//  Created by Bobby Ren on 1/27/13.
//
//

#import "CreateProfilePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+GaussianBlur.h"
#import "UIImage+Resize.h"
#import "AWSHelper.h"
#import "AppDelegate.h"

@interface CreateProfilePhotoViewController ()

@end

@implementation CreateProfilePhotoViewController

@synthesize photoView, buttonChangePhoto, slider;
@synthesize userInfo;
@synthesize delegate;
@synthesize stepButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Photo";
        
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(didClickNext:)];
        rightButton.tintColor = [UIColor orangeColor];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        self.navigationItem.backBarButtonItem.tintColor = [UIColor blueColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.buttonChangePhoto.layer setCornerRadius:5];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.stepButton setSelected:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)populateWithUserInfo:(UserInfo*)newUserInfo {
    self.userInfo = newUserInfo;
    
    // force photoView to update
    int startPrivacyLevel = self.userInfo.privacyLevel;
    self.userInfo.privacyLevel = startPrivacyLevel+1; // hack to force update
    [self.slider setValue:startPrivacyLevel];
    [self sliderDidChangeValue:self.slider];
}

-(IBAction)sliderDidChangeValue:(id)sender {
    UISlider * slider = (UISlider*)sender;
    int newPrivacyLevel = (int) (slider.value);
    if (newPrivacyLevel == self.userInfo.privacyLevel)
        return;
    
    UIImage * newImage;
    
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
            newImage = [[[self resizeImage:userInfo.photo byScale:.5] imageWithGaussianBlur] imageWithGaussianBlur];
            break;
        case 4:
            newImage = [[self resizeImage:userInfo.photo byScale:.25] imageWithGaussianBlur];
            break;
        case 5:
            newImage = [[[self resizeImage:userInfo.photo byScale:.25] imageWithGaussianBlur] imageWithGaussianBlur];
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

#pragma mark navigation

-(void)didClickNext:(id)sender {
    NSLog(@"Next!");
    userInfo.photoBlur = photoView.image;
    [self.delegate didSaveProfilePhoto];
}

-(IBAction)didClickProfileInfo:(id)sender {
    // go back
    [self.stepButton setSelected:NO];
    self.userInfo.privacyLevel = slider.value;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)didClickProfilePreview:(id)sender {
    // go forward
    [self.stepButton setSelected:NO];
    [self didClickNext:sender];
}

#pragma mark changing photo
-(IBAction)didClickChangePhotoButton:(id)sender {
    NSLog(@"Changing photo!");
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.navigationController.navigationBar.tintColor = [UIColor colorWithRed:23.0/255 green:153.0/255 blue:228.0/255 alpha:1];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.allowsEditing = YES;
    //picker.showsCameraControls = YES;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	UIImage * origImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage * editImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [self.slider setValue:0];
    [photoView setImage:origImage];
    userInfo.photo = origImage;
    if (editImage) {
        [photoView setImage:editImage];
        userInfo.photo = editImage;
    }
}
@end
