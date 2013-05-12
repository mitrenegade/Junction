//
//  SettingsEditGoalsViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/7/13.
//
//

#import "SettingsEditGoalsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

static AppDelegate * appDelegate;

@interface SettingsEditGoalsViewController ()

@end

@implementation SettingsEditGoalsViewController

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
    titleView.text = @"Goals";
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
    
    UIToolbar* keyboardDoneButtonView1 = [[UIToolbar alloc] init];
    keyboardDoneButtonView1.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView1.translucent = YES;
    keyboardDoneButtonView1.tintColor = nil;
    [keyboardDoneButtonView1 sizeToFit];
    UIBarButtonItem* doneButton1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                    style:UIBarButtonItemStyleBordered target:self
                                                                   action:@selector(doneEditing:)];
    [keyboardDoneButtonView1 setItems:[NSArray arrayWithObjects:doneButton1, nil]];
    textViewLookingFor.inputAccessoryView = keyboardDoneButtonView1;
    textViewTalkAbout.inputAccessoryView = keyboardDoneButtonView1;
    [textViewLookingFor.layer setCornerRadius:5];
    [textViewTalkAbout.layer setCornerRadius:5];
    [textViewLookingFor.layer setBorderColor:[COLOR_LIGHTBLUE CGColor]];
    [textViewTalkAbout.layer setBorderColor:[COLOR_LIGHTBLUE CGColor]];
    [textViewLookingFor.layer setBorderWidth:1];
    [textViewTalkAbout.layer setBorderWidth:1];
    
    [labelLookingFor setFont:[UIFont fontWithName:@"SansusWebissimo" size:12]];
    [labelTalkAbout setFont:[UIFont fontWithName:@"SansusWebissimo" size:12]];
    [labelLookingFor setTextColor:COLOR_LIGHTBLUE];
    [labelTalkAbout setTextColor:COLOR_LIGHTBLUE];

    UserInfo * myUserInfo = appDelegate.myUserInfo;
    textViewLookingFor.text = myUserInfo.lookingFor;
    textViewTalkAbout.text = myUserInfo.talkAbout;

    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    //keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    currentTextView = nil;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    currentTextView = textView;
    return YES;
}

-(void)doneEditing:(id)sender {
    // don't save here
    [textViewLookingFor resignFirstResponder];
    [textViewTalkAbout resignFirstResponder];
}

-(void)goBack:(id)sender {
    // save
    UserInfo * myUserInfo = appDelegate.myUserInfo;
    myUserInfo.talkAbout = textViewTalkAbout.text;
    myUserInfo.lookingFor = textViewLookingFor.text;
    [[myUserInfo toPFObject] saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Personal information Updated!");
            [[NSNotificationCenter defaultCenter] postNotificationName:kMyUserInfoDidChangeNotification object:nil];
        }
        else {
            NSLog(@"Saving personal information error: %@", error);
        }
    }];
    // dismiss
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark scrollview and keyboard
- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        [scrollView setFrame:self.view.frame];
        //        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the sizshouldbegine of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= (keyboardSize.height);// - kTabBarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [scrollView setFrame:viewFrame];
    CGPoint contentOffset;
    if (currentTextView == textViewLookingFor)
        contentOffset = CGPointMake(0, labelLookingFor.frame.origin.y);
    else if (currentTextView == textViewTalkAbout)
        contentOffset = CGPointMake(0, labelTalkAbout.frame.origin.y);
    else
        contentOffset = scrollView.contentOffset;
    [scrollView setContentOffset:contentOffset];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += (keyboardSize.height);// - kTabBarHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    [scrollView setFrame:viewFrame];
    [scrollView setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

-(void)hideKeyboard {
    [textViewLookingFor resignFirstResponder];
    [textViewTalkAbout resignFirstResponder];
}

@end
