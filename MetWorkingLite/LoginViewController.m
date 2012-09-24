//
//  LoginViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "OAuthLoginView.h"
#import "UIImage+Resize.h"

#import "AppDelegate.h" // for notification constants

static CGRect originalScrollViewFrame;

@implementation LoginViewController

@synthesize buttonPhoto, usernameField, emailField;
@synthesize delegate;
@synthesize scrollView;
@synthesize lhHelper;
@synthesize myUserInfo;
@synthesize buttonLinkedIn, labelLinkedIn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"Log In"];
        
#if 0
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStylePlain target:self action:@selector(didClickGoButton:)];
        [self.navigationItem setRightBarButtonItem:rightButton];
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:self.view.window];

    // notification for changes to myUserInfo - due to linkedIn login
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateMyUserInfo) 
                                                 name:kMyUserInfoDidChangeNotification 
                                               object:nil];
    keyboardIsShown = NO;
    originalScrollViewFrame = scrollView.frame;

    [self.navigationController setNavigationBarHidden:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:UIKeyboardWillShowNotification  
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:UIKeyboardWillHideNotification  
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [buttonPhoto.layer setBorderWidth:2];
    [buttonPhoto.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [buttonPhoto.layer setCornerRadius:5];
    [buttonPhoto.imageView.layer setCornerRadius:5];

    [self updateMyUserInfo];
}

-(void) dealloc {
    // valid for arc?
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:kMyUserInfoDidChangeNotification  
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:UIKeyboardWillShowNotification  
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:UIKeyboardWillHideNotification  
                                                  object:nil];

}

-(void)updateMyUserInfo {
    myUserInfo = [delegate getMyUserInfo];
    [usernameField setText:[myUserInfo username]];
    [emailField setText:[myUserInfo email]];
    // adjust font
    CGSize textSize = [emailField.text sizeWithFont:emailField.font];
    while (textSize.width > emailField.frame.size.width && emailField.font.pointSize > 10) {
        emailField.font = [UIFont systemFontOfSize:emailField.font.pointSize - 1];
    }
    if ([myUserInfo photo])
        [buttonPhoto setImage:[myUserInfo photo] forState:UIControlStateNormal];
    [labelLinkedIn setText:[myUserInfo headline]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initializeWithUserInfo:(UserInfo *)_myUserInfo {
    [self setMyUserInfo:_myUserInfo];
    NSLog(@"Initializing with existing userinfo: %@ %@", [myUserInfo username], [myUserInfo email]);
}

#pragma mark outlet actions
-(IBAction)didClickPhotoButton:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; ////SavedPhotosAlbum;
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    // because a modal camera already exists, we must present a modal view over that camera
    [self presentModalViewController:picker animated:YES];
}

-(void)didClickBackButton:(id)sender {
    [delegate didSelectUsername:[usernameField text] andEmail:[emailField text] andPhoto:[[buttonPhoto imageView] image]];
    [self.navigationController popViewControllerAnimated:YES];
    //    [self.navigationController pushViewController:lhHelper animated:YES];
}

-(IBAction)didClickGoButton:(id)sender {
    if ([usernameField text] == nil)
        return;
    if ([emailField text] == nil)
        return;

    [delegate didSelectUsername:[usernameField text] andEmail:[emailField text] andPhoto:[[buttonPhoto imageView] image]];
}

#pragma mark UIImagePickerControllerDelegate
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated:TRUE];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage * originalPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * newPhoto; 
    if (editedPhoto)
        newPhoto = editedPhoto;
    else
        newPhoto = originalPhoto; 
    
    NSLog(@"Finished picking image: dimensions %f %f", newPhoto.size.width, newPhoto.size.height);
    [self dismissModalViewControllerAnimated:TRUE];
    
    // scale down photo
	CGSize targetSize = CGSizeMake(100, 100);		
    UIImage * result = [newPhoto resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    [buttonPhoto setImage:result forState:UIControlStateNormal];
    [buttonPhoto.imageView.layer setCornerRadius:5];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == usernameField)
        [emailField becomeFirstResponder];
    
    // resize
    CGSize textSize = [textField.text sizeWithFont:textField.font];
    while (textSize.width > textField.frame.size.width && textField.font.pointSize > 10) {
        textField.font = [UIFont systemFontOfSize:textField.font.pointSize - 1];
    }

	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    currentField = textField;
    return YES;
}

#pragma mark scrollview and keyboard
- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        [scrollView setFrame:originalScrollViewFrame];
//        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the sizshouldbegine of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= (keyboardSize.height);// - kTabBarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.scrollView setFrame:viewFrame];
    CGPoint contentOffset;
    if (currentField == usernameField)
        contentOffset = CGPointMake(0, usernameField.frame.origin.y - 20);
    else if (currentField == emailField)
        contentOffset = CGPointMake(0, emailField.frame.origin.y - 20);
    [self.scrollView setContentOffset:contentOffset];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += (keyboardSize.height);// - kTabBarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [self.scrollView setFrame:viewFrame];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

#pragma mark LinkedInHelper

-(IBAction)didClickLinkedIn:(id)sender {
#if 1
    lhHelper = [[LinkedInHelper alloc] init];
    [lhHelper setDelegate:self];
    OAuthLoginView * lhView = [lhHelper loginView];
    //[self presentModalViewController:lhView animated:YES];
    //[self.navigationController pushViewController:lhView animated:NO];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.view addSubview:lhView.view];
#else
    [delegate didClickLinkedIn];
#endif
}

#pragma mark LinkedInHelperDelegate 

-(void)linkedInDidLoginWithID:(NSString *)userID {
    linkedInString = [userID copy];
    
    // pop linkedIn (oauthViewController)
    //[self dismissModalViewControllerAnimated:NO];
    [lhHelper closeLoginView];
    
    // request profile info
    [lhHelper requestAllProfileInfoForID:userID];
}

#pragma mark linkedInHelperDelegate
-(void)linkedInParseProfileInformation:(NSDictionary*)profile {
    // returns the following information: first-name,last-name,industry,location:(name),specialties,summary,picture-url,email-address,educations,three-current-positions
    [delegate didLoginWithLinkedInString:linkedInString andProfileInformation:profile];
}

@end
