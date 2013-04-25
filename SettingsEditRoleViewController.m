//
//  SettingsEditRoleViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import "SettingsEditRoleViewController.h"
#import "AppDelegate.h"
#import "IndustryFilterTableViewController.h"

static AppDelegate * appDelegate;

@interface SettingsEditRoleViewController ()

@end

@implementation SettingsEditRoleViewController

@synthesize delegate;
@synthesize roleIndex, industry, position, company;

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
    // make a custom header label
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIImage * headerbg = [UIImage imageNamed:@"header_bg"];
    [self.navigationController.navigationBar setBackgroundImage:headerbg forBarMetrics:UIBarMetricsDefault];
    
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [titleView setFont:[UIFont boldSystemFontOfSize:23]];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:158.0/255.0 blue:205.0/255.0 alpha:1]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    titleView.text = @"Add Role";
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
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithCustomView:buttonSave];
    [self.navigationItem setRightBarButtonItem:saveButton];

    tableView.backgroundColor = COLOR_FAINTBLUE;
    
    if (self.position)
        [inputPosition setText:self.position];
    if (self.company)
        [inputCompany setText:self.company];
    if (self.industry)
        [inputIndustry setText:self.industry];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender {
    // dismiss
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)didClickSave:(id)sender {
    NSLog(@"Saved!");

    [delegate didSaveRoleAtIndex:self.roleIndex withPosition:inputPosition.text withCompany:inputCompany.text withIndustry:inputIndustry.text];
}

// todo: check ios5 vs ios6 behavior
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"Start editing");
    if (textField == inputIndustry) {
        IndustryFilterTableViewController * industryFilterTable = [[IndustryFilterTableViewController alloc] init];
        [industryFilterTable setDelegate:self];
        [self.navigationController pushViewController:industryFilterTable animated:YES];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == inputPosition)
        [inputCompany becomeFirstResponder];
    else if (textField == inputCompany)
        [inputIndustry becomeFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark IndustryFieldDelegate
-(void)didSelectIndustryFilter:(NSString *)industry {
    [self.navigationController popToViewController:self animated:YES];
    [inputIndustry resignFirstResponder];
    inputIndustry.text = industry;
}

@end
