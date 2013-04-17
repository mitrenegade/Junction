//
//  SettingsEditRoleViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import "SettingsEditRoleViewController.h"
#import "AppDelegate.h"

static AppDelegate * appDelegate;

@interface SettingsEditRoleViewController ()

@end

@implementation SettingsEditRoleViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
