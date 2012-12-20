//
//  ProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h" // for notification constants

#define CELL_LABEL_TAG 1001

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize photoView;
@synthesize myUserInfo;
@synthesize delegate;
@synthesize userDescription;
@synthesize nameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_me"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setMyUserInfo:[delegate getMyUserInfo]];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateMyUserInfo) 
                                                 name:kMyUserInfoDidChangeNotification 
                                               object:nil];
    
    userDescription = [[UserDescriptionViewController alloc] init];
    [userDescription.view setFrame:CGRectMake(0, photoView.frame.origin.y + photoView.frame.size.height, 320, 200)];
    [self.view addSubview:userDescription.view];
}

-(void)updateMyUserInfo {
    myUserInfo = [delegate getMyUserInfo];
    [photoView setImage:myUserInfo.photo];
    [nameLabel setText:myUserInfo.username];
    [self.userDescription setTitle:myUserInfo.headline];
    [self.userDescription setIndustry:myUserInfo.industry];
    [self.userDescription setDescription:myUserInfo.summary];
    [self.userDescription refreshDescription];
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
}
-(void)dealloc {
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self    
                                                    name:kMyUserInfoDidChangeNotification  
                                                  object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateMyUserInfo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*

-(void)addFilter:(NSString*)description {
    NSMutableDictionary * filter = [[NSMutableDictionary alloc] initWithObjectsAndKeys:description, @"description", nil];
    [filters addObject:filter];
    
    [tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // may have more than one distance -> sections
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"About me";
            break;
            
        case 1:
            return @"My Filters";
            break;
            
        default:
            break;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    //[headerView setBackgroundColor:[UIColor clearColor]];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 260, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setTextColor:[UIColor whiteColor]];
    //[headerView addSubview:label];
    switch (section) {
        case 0:
            [label setText:@"About me"];
            break;
            
        case 1:
            [label setText:@"My Filters"];
            break;
            
        default:
            break;
    }
    return label;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // About me
        return myUserInfo.numberOfFields;
    }
    else if (section == 1) {
        // My Filters
        return [filters count] + 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.backgroundView = [[UIImageView alloc] init];
//        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        
        UILabel * cellContent = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 180, 44)];
        [cellContent setTag:CELL_LABEL_TAG];
        [cellContent setFont:[UIFont systemFontOfSize:12]];
        [cellContent setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:cellContent];
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int row = [indexPath row];
    
    UILabel * cellContent = (UILabel*)[cell.contentView viewWithTag:CELL_LABEL_TAG];
    
    if (section == 0) {
        // About me
        switch (row) {
            case 0:
                [cell.textLabel setText:@"My email"];
                [cellContent setText:myUserInfo.email];
                break;
                
            case 1:
                [cell.textLabel setText:@"My headline"];
                [cellContent setText:myUserInfo.headline];
                break;
            
            case 2:
                [cell.textLabel setText:@"My position"];
                [cellContent setText:myUserInfo.position];
                break;
                
            case 3: 
                [cell.textLabel setText:@"My location"];
                [cellContent setText:myUserInfo.location];
                break;
                
            case 4:
                [cell.textLabel setText:@"My industry"];
                [cellContent setText:myUserInfo.industry];
                break;
                
            case 5:
                [cell.textLabel setText:@"A summary about me"];
                [cellContent setText:myUserInfo.summary];
                break;
                
            default:
                break;
        }
    }
    else if (section == 1) {
        // my filters
        if (row > [filters count] + 1)
            return nil;
        if (row == [filters count]) {
            [cell.textLabel setText:@"Add a filter"];
            [cellContent setText:@""];
        }
        else {
            NSMutableDictionary * filter = [filters objectAtIndex:row];
            [cell.textLabel setText:[filter objectForKey:@"description"]];
            [cellContent setText:@""];
        }
    }
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // about me
        InputViewController * input = [[InputViewController alloc] init];
        [input setDelegate:self];
        [input setInputTag:indexPath.row];
        switch (indexPath.row) {
            case 0:
                [input setInitialText:myUserInfo.email];
                [input setLabelText:@"My email"];
                break;
            case 1:
                [input setInitialText:myUserInfo.headline];
                [input setLabelText:@"My headline"];
                break;
            case 2:
                [input setInitialText:myUserInfo.position];
                [input setLabelText:@"My position"];
                break;
                
            default:
                break;
        }
        [self.navigationController pushViewController:input animated:YES];
    }
    else if (indexPath.section == 1) {
        // filters
        if (indexPath.row == [filters count]) {
            NSLog(@"Adding filter!");
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark inputViewDelegate

-(void)didGetInput:(NSString *)text forTag:(int)tag {
    switch (tag) {
        case 0:
            [myUserInfo setEmail:text];
            break;
        case 1:
            [myUserInfo setHeadline:text];
            break;
        case 2:
            [myUserInfo setPosition:text];
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"myUserInfoDidChange" object:self userInfo:nil];
}
*/
@end
