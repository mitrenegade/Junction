//
//  SettingsNotificationsViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import "SettingsNotificationsViewController.h"

@interface SettingsNotificationsViewController ()

@end

@implementation SettingsNotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    titleView.text = @"Notifications";
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    self.navigationItem.titleView = titleView;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon-back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(10, 0, 30, 30)];
    UIBarButtonItem * backbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:backbutton];
    
    tableView.backgroundColor = COLOR_FAINTBLUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didToggle:(id)sender {
    UISwitch * toggle = (UISwitch*)sender;
    if (toggle == toggleNotifyAccept) {
        NSLog(@"Change notification for when request is accepted");
    }
    else if (toggle == toggleNotifyFollowup) {
        NSLog(@"Change notification for follow reminder");
    }
    else if (toggle == toggleNotifyReceive) {
        NSLog(@"Change notification for when request is received");
    }
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if (row == 0) {
                cell.textLabel.text = @"I receive a connection request";
                cell.accessoryView = toggleNotifyReceive;
            }
            else if (row == 1) {
                cell.textLabel.text = @"A request I sent is accepted";
                cell.accessoryView = toggleNotifyAccept;
            }
            else if (row == 2) {
                cell.textLabel.text = @"It's time to follow up";
                cell.accessoryView = toggleNotifyFollowup;
            }
        }
            break;
            
        case 1:
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if (row == 0) {
                cell.textLabel.text = @"1 week after I connect";
                cell.accessoryView = nil;
                if (weeksForFollowupReminder == 1)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else if (row == 1) {
                cell.textLabel.text = @"2 weeks after I connect";
                cell.accessoryView = nil;
                if (weeksForFollowupReminder == 2)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else if (row == 2) {
                cell.textLabel.text = @"3 weeks after I connect";
                cell.accessoryView = nil;
                if (weeksForFollowupReminder == 3)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
                        
        default:
            break;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    int index;
    if (section == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"Notify me when"];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        return view;
    }
    else if (section == 1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"Remind me to follow up"];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        return view;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            // do nothing here
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0) {
                NSLog(@"1 week");
                weeksForFollowupReminder = 1;
                [tableView reloadData];
            }
            else if (indexPath.row == 1) {
                NSLog(@"2 week");
                weeksForFollowupReminder = 2;
                [tableView reloadData];
            }
            else if (indexPath.row == 2) {
                NSLog(@"3 week");
                weeksForFollowupReminder = 3;
                [tableView reloadData];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)goBack:(id)sender {
    // save
    
    // dismiss
    [self.navigationController popViewControllerAnimated:YES];
}

@end
