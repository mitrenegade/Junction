//
//  FilterViewController.m
//  Junction
//
//  Created by Bobby Ren on 3/5/13.
//
//

#import "FilterViewController.h"
#import "AppDelegate.h"

@interface FilterViewController ()

@end

static AppDelegate * appDelegate;

@implementation FilterViewController

@synthesize labelTitle, buttonFilter, tableView;
@synthesize viewsForCell;
@synthesize companyFilter, industryFilter, friendsFilter;
@synthesize companyField, industryField, friendsSwitch;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.viewsForCell = [[NSMutableArray alloc] init];
    for (int i=0; i<15; i++) {
        [self.viewsForCell addObject:[NSNull null]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickFilter:(id)sender {
    NSLog(@"Did click filter");
    
    [self.companyField resignFirstResponder];
    
    [self.delegate doFilter];
    [self.delegate closeFilter];
}

-(IBAction)didClickClear:(id)sender {
    [self.companyField resignFirstResponder];

    self.industryFilter = nil;
    self.companyFilter = nil;
    self.positionFilter = nil;
    self.friendsFilter = NO;
    
    self.industryField.text = @"";
    self.companyField.text = @"";
    self.positionField.text = @"";
    [self.friendsSwitch setOn:NO];
    
    [self.delegate doFilter];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    if (section == 1)
        return 1;
    return 0;
}

-(UIView*)viewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    int index;
    if (section == 0) {
        if (row == INPUT_FILTER_INDUSTRY && [self.viewsForCell objectAtIndex:INPUT_FILTER_INDUSTRY] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_FILTER_INDUSTRY];
        }
        if (row == INPUT_FILTER_COMPANY && [self.viewsForCell objectAtIndex:INPUT_FILTER_COMPANY] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_FILTER_COMPANY];
        }
        if (row == INPUT_FILTER_POSITION && [self.viewsForCell objectAtIndex:INPUT_FILTER_POSITION] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_FILTER_POSITION];
        }
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 300, FILTER_ROW_HEIGHT)];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, FILTER_ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:12]];
        [label setTextColor:[UIColor colorWithRed:105.0/255 green:200.0/255 blue:255.0/255 alpha:1]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        
        if (row == INPUT_FILTER_INDUSTRY) {
            UIImageView * forward = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward_arrows"]];
            [forward setFrame:CGRectMake(250, 0, 40, 40)];
            [view addSubview:forward];
            UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, 200, FILTER_ROW_HEIGHT)];
            [inputField setTextAlignment:NSTextAlignmentLeft];
            [inputField setFont:[UIFont boldSystemFontOfSize:15]];
            inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
            [inputField setUserInteractionEnabled:NO];
            [inputField setClearButtonMode:UITextFieldViewModeUnlessEditing];
            if ([self.industryFilter length])
                inputField.text = self.industryFilter;
            [view addSubview:inputField];
            
            self.industryField = inputField;
            
            [label setText:@"INDUSTRY"];
            index = INPUT_FILTER_INDUSTRY;
        }
        else if (row == INPUT_FILTER_COMPANY) {
            UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, 200, FILTER_ROW_HEIGHT)];
            [inputField setTextAlignment:NSTextAlignmentLeft];
            [inputField setFont:[UIFont boldSystemFontOfSize:15]];
            inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
            [inputField setPlaceholder:@"Type company name"];
            [inputField setDelegate:self];
            [inputField setClearButtonMode:UITextFieldViewModeUnlessEditing];
            if ([self.companyFilter length])
                inputField.text = self.companyFilter;
            [view addSubview:inputField];
            
            self.companyField = inputField;
            
            [label setText:@"COMPANY"];
            index = INPUT_FILTER_COMPANY;
        }
        else if (row == INPUT_FILTER_POSITION) {
            UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, 200, FILTER_ROW_HEIGHT)];
            [inputField setTextAlignment:NSTextAlignmentLeft];
            [inputField setFont:[UIFont boldSystemFontOfSize:15]];
            inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
            [inputField setPlaceholder:@"e.g. Product Manager"];
            [inputField setDelegate:self];
            [inputField setClearButtonMode:UITextFieldViewModeUnlessEditing];
            if ([self.positionFilter length])
                inputField.text = self.positionFilter;
            [view addSubview:inputField];
            
            self.positionField = inputField;
            
            [label setText:@"POSITION"];
            index = INPUT_FILTER_POSITION;
        }
        [view addSubview:label];
        
        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        return [self.viewsForCell objectAtIndex:index];
    }
    else if (section == 1) {
        if (row == 0 && [self.viewsForCell objectAtIndex:INPUT_FILTER_FRIENDS] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_FILTER_FRIENDS];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, FILTER_ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:12]];
        [label setTextColor:[UIColor colorWithRed:105.0/255 green:200.0/255 blue:255.0/255 alpha:1]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"FRIENDS IN COMMON"];
        
        UISwitch * toggle = [[UISwitch alloc] init];
        [toggle setFrame:CGRectMake(200, 5, 120, FILTER_ROW_HEIGHT-10)];
        [toggle addTarget:self action:@selector(didToggleFriendsFilter:) forControlEvents:UIControlEventValueChanged];
        
        if (self.friendsFilter)
            [toggle setOn:YES];
        
        self.friendsSwitch = toggle;
        
        index = INPUT_FILTER_FRIENDS;
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 300, FILTER_ROW_HEIGHT)];
        [view addSubview:label];
        [view addSubview:toggle];
        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        return [self.viewsForCell objectAtIndex:index];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
    //    for (UIView * subview in cell.subviews)
    //        [subview removeFromSuperview];
    [cell addSubview:[self viewForItemAtIndexPath:indexPath]];
    return cell;
}

-(void)didToggleFriendsFilter:(id)sender {
    [self.companyField resignFirstResponder];
    
    self.friendsFilter = !self.friendsFilter;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterChanged object:self userInfo:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = indexPath.section;
    int row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            // INDUSTRY filter
            IndustryFilterTableViewController * industryFilterTable = [[IndustryFilterTableViewController alloc] init];
            [industryFilterTable setDelegate:self];
            //[self presentModalViewController:industryFilterTable animated:YES];
            [appDelegate.window.rootViewController presentModalViewController:industryFilterTable animated:YES];
        }
    }
}

-(void)didSelectIndustryFilter:(NSString *)industry {
    //[self dismissModalViewControllerAnimated:YES];
    [appDelegate.window.rootViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Filter selected: %@", industry);
    self.industryFilter = industry;
    [self.industryField setText:self.industryFilter];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FILTER_ROW_HEIGHT;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == self.companyField)
        [self.positionField becomeFirstResponder];
    
    self.companyFilter = self.companyField.text;
    self.positionFilter = self.positionField.text;
	return YES;
}

@end
