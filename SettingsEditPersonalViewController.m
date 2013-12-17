//
//  SettingsEditPersonalViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/7/13.
//
//

#import "SettingsEditPersonalViewController.h"
#import "AppDelegate.h"

static AppDelegate * appDelegate;

@interface SettingsEditPersonalViewController ()

@end

@implementation SettingsEditPersonalViewController

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
    titleView.text = @"Personal";
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
    
    UserInfo * myUserInfo = appDelegate.myUserInfo;
    textFieldName.text = myUserInfo.username;
    textFieldEmail.text = myUserInfo.email;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    // don't save here
    return YES;
}

-(void)goBack:(id)sender {
    // save
    UserInfo * myUserInfo = appDelegate.myUserInfo;
    myUserInfo.username = textFieldName.text;
    myUserInfo.email = textFieldEmail.text;
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

@end
