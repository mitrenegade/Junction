//
//  SettingsViewController.m
//  Junction
//
//  Created by Bobby Ren on 3/1/13.
//
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "SettingsNotificationsViewController.h"
#import "SettingsEditProfileViewController.h"
#import "TutorialViewController.h"

static AppDelegate * appDelegate;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar-settings"]];
        [self.tabBarItem setTitle:@"Settings"];
        
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
    titleView.text = @"Settings";
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    self.navigationItem.titleView = titleView;
    
    tableView.backgroundColor = COLOR_FAINTBLUE;
    
    [toggleVisibility setOn:appDelegate.myUserInfo.isVisible];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    if (section == 1)
        return 3;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int section = [indexPath section];
    int row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    switch (section) {
        case 0:
        {
            cell.accessoryView = self.accessoryRightArrow;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if (row == 0) {
                cell.textLabel.text = @"See help again";
            }
            else if (row == 1) {
                cell.textLabel.text = @"Invite friends";
            }
        }
            break;
            
        case 1:
        {
            cell.accessoryView = self.accessoryRightArrow;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if (row == 0) {
                cell.textLabel.text = @"Visibility";
                cell.accessoryView = toggleVisibility;
            }
            else if (row == 1) {
                cell.textLabel.text = @"Profile";
            }
            else if (row == 2) {
                cell.textLabel.text = @"Notifications";
            }
        }
            break;
            
        case 2:
        {
            cell.accessoryView = self.accessoryRightArrow;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            if (row == 0) {
                cell.textLabel.text = @"Send feedback";
            }
            else if (row == 1) {
                cell.textLabel.text = @"Log out";
            }
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                NSLog(@"See help again");
                TutorialViewController * controller = [[TutorialViewController alloc] init];
                [controller setForceDone:YES];
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
                [self presentModalViewController:nav animated:YES];
            }
            else if (indexPath.row == 1) {
                NSLog(@"Invite friends");
            }
        }
            break;

        case 1:
        {
            if (indexPath.row == 0) {
                NSLog(@"Visibility");
            }
            else if (indexPath.row == 1) {
                NSLog(@"Profile");
                SettingsEditProfileViewController * controller = [[SettingsEditProfileViewController alloc] init];
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
                //[self.navigationController pushViewController:controller animated:YES];
                [self presentModalViewController:nav animated:YES];
            }
            else if (indexPath.row == 2) {
                NSLog(@"Notifications");
                SettingsNotificationsViewController * controller = [[SettingsNotificationsViewController alloc] init];
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
                //[self.navigationController pushViewController:controller animated:YES];
                [self presentModalViewController:nav animated:YES];
            }
        }
            break;

        case 2:
        {
            if (indexPath.row == 0) {
                NSLog(@"Feedback");
                [appDelegate sendFeedback:@"General comments"];
            }
            else if (indexPath.row == 1) {
                NSLog(@"Log out");
                [appDelegate logout];
            }
        }
            break;

        default:
            break;
    }
}

-(IBAction)didToggleVisibility:(id)sender {
    NSLog(@"Toggled!");
    
    BOOL oldIsOn = appDelegate.myUserInfo.isVisible;
    appDelegate.myUserInfo.isVisible = toggleVisibility.isOn;
    [toggleVisibility setEnabled:NO];
    [appDelegate.myUserInfo.toPFObject saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Visibility toggle succeeded!");
            [toggleVisibility setEnabled:YES];
        }
        else {
            NSLog(@"Visibility toggle could not be saved!");
            appDelegate.myUserInfo.isVisible = oldIsOn;
            [toggleVisibility setOn:oldIsOn];
            [toggleVisibility setEnabled:YES];
        }
    }];
}

-(UIImageView*)accessoryRightArrow {
    UIImageView * accessoryRightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn-field-arrow.png"]];
    [accessoryRightArrow setFrame:CGRectMake(0, 0, 17, 25)];
    return accessoryRightArrow;
}
@end
