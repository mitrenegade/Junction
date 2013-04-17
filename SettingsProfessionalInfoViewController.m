//
//  SettingsProfessionalInfoViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import "SettingsProfessionalInfoViewController.h"
#import "AppDelegate.h"

static AppDelegate * appDelegate;

@interface SettingsProfessionalInfoViewController ()

@end

@implementation SettingsProfessionalInfoViewController

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
    titleView.text = @"Professional Info";
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
    
    tableView.backgroundColor = COLOR_FAINTBLUE;
    
    buttonAddRole = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAddRole setFrame:CGRectMake(-5, -1, 310, 46)];
    [buttonAddRole setBackgroundImage:[UIImage imageNamed:@"btn-secondary-up"] forState:UIControlStateNormal];
    [buttonAddRole setBackgroundImage:[UIImage imageNamed:@"btn-secondary-press"] forState:UIControlStateHighlighted];
    [buttonAddRole addTarget:self action:@selector(didClickAddRole:) forControlEvents:UIControlEventTouchUpInside];
    [buttonAddRole setTitle:@"Add a Role" forState:UIControlStateNormal];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [appDelegate.myUserInfo.currentPositions count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    int row = [indexPath row]; //[chatData count]-[indexPath row]-1;    
    int section = [indexPath section];
    switch (section) {
        case 0:
        {
            NSDictionary * currPos = [appDelegate.myUserInfo.currentPositions objectAtIndex:indexPath.row];
            NSLog(@"CurrPos %d: %@", row, currPos);

            [cell setBackgroundColor:[UIColor whiteColor]];
            cell.accessoryView = self.accessoryRightArrow;
            cell.textLabel.text = [currPos objectForKey:@"title"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [[currPos objectForKey:@"company"] objectForKey:@"name"], [[currPos objectForKey:@"company"] objectForKey:@"industry"]];
        }
            break;
            
        case 1:
        {
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundView:nil];
            cell.accessoryView = nil;
            [buttonAddRole removeFromSuperview];
            [cell.contentView addSubview:buttonAddRole];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(UIImageView*)accessoryRightArrow {
    UIImageView * accessoryRightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn-field-arrow.png"]];
    [accessoryRightArrow setFrame:CGRectMake(0, 0, 17, 25)];
    return accessoryRightArrow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return HEADER_HEIGHT;
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    int index;
    if (section == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"YOUR RECENT ROLES"];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        return view;
    }
    else if (section == 1) {
        return nil;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            // edit role
        }
            break;
            
        default:
            break;
    }
}

-(void)didClickAddRole:(id)sender {
    NSLog(@"Add a new role!");
    if (!appDelegate.myUserInfo.currentPositions) {
        appDelegate.myUserInfo.currentPositions = [[NSMutableArray alloc] init];
    }
}

-(void)didClickPullFromLinkedIn:(id)sender {
    NSLog(@"Pull from linkedIn");
}

-(void)goBack:(id)sender {
    // save
    
    // dismiss
    [self.navigationController popViewControllerAnimated:YES];
}

@end
