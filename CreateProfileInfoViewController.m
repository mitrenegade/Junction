//
//  CreateProfileInfoViewController.m
//  Junction
//
//  Created by Bobby Ren on 1/27/13.
//
//

#import "CreateProfileInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateProfileInfoViewController ()

@end

@implementation CreateProfileInfoViewController

@synthesize inputFields;
@synthesize userInfo;
@synthesize tableView;
@synthesize delegate;
@synthesize stepButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Info";
        
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(didClickNext:)];
        rightButton.tintColor = [UIColor orangeColor];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.inputFields = [[NSMutableArray alloc] init];
    for (int i=0; i<15; i++)
        [self.inputFields addObject:[NSNull null]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.stepButton setSelected:YES]; // fake nav buttons
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)populateWithUserInfo:(UserInfo*)newUserInfo {
    self.userInfo = newUserInfo;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2)
        return 200;
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    if (section == 1)
        return 3;
    if (section == 2)
        return 1;
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Personal Information";
    }
    else if (section == 1) {
        return @"Professional Information";
    }
    else if (section == 2) {
        return @"What are you looking for?";
    }
    return nil;
}

-(UIView*)viewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ROW_HEIGHT)];
    int index;
    if (section == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        [label setBackgroundColor:[UIColor colorWithRed:165.0/255 green:211.0/255 blue:228.0/255 alpha:1]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, ROW_HEIGHT)];
        [inputField setTextAlignment:NSTextAlignmentLeft];
        [inputField setFont:[UIFont boldSystemFontOfSize:15]];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputField setDelegate:self];
        if (row == 0) {
            index = 0;
            [label setText:@"NAME"];
            [inputField setPlaceholder:@"Your preferred name"];
            if (self.userInfo.username)
                [inputField setText:self.userInfo.username];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 1) {
            index = 1;
            [label setText:@"EMAIL"];
            [inputField setPlaceholder:@"example@example.com"];
            if (self.userInfo.email)
                [inputField setText:self.userInfo.email];
            [inputField setKeyboardType:UIKeyboardTypeEmailAddress];
        }

        [view addSubview:label];
        [view addSubview:inputField];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
    }
    else if (section == 1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        [label setBackgroundColor:[UIColor colorWithRed:165.0/255 green:211.0/255 blue:228.0/255 alpha:1]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, ROW_HEIGHT)];
        [inputField setTextAlignment:NSTextAlignmentLeft];
        [inputField setFont:[UIFont boldSystemFontOfSize:15]];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputField setDelegate:self];
        if (row == 0) {
            index = 2;
            [label setText:@"ROLE"];
            [inputField setPlaceholder:@""];
            if (self.userInfo.headline)
                [inputField setText:self.userInfo.headline];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 1) {
            index = 3;
            [label setText:@"COMPANY"];
            [inputField setPlaceholder:@""];
            if (self.userInfo.company)
                [inputField setText:self.userInfo.company];
            [inputField setKeyboardType:UIKeyboardTypeURL];
        }
        else if (row == 2) {
            index = 4;
            [label setText:@"INDUSTRY"];
            [inputField setPlaceholder:@"optional"];
            if (self.userInfo.industry)
                [inputField setText:self.userInfo.industry];
            [inputField setKeyboardType:UIKeyboardTypeURL];
        }
        
        [view addSubview:label];
        [view addSubview:inputField];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
    }
    else if (section == 2) {
        int index = 5;
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 300, 200)];
        [textField.layer setCornerRadius:5];
        [textField setFont:[UIFont boldSystemFontOfSize:15]];
        [view addSubview:textField];
        [inputFields replaceObjectAtIndex:index withObject:textField];
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
    for (UIView * subview in cell.subviews)
        [subview removeFromSuperview];
    [cell addSubview:[self viewForItemAtIndexPath:indexPath]];
    return cell;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    /*
    if (textField == [inputFields objectAtIndex:0])
        [[inputFields objectAtIndex:1] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:1])
        [[inputFields objectAtIndex:2] becomeFirstResponder];
    */
	return YES;
}

#pragma mark navigation

-(IBAction)didClickNext:(id)sender {
    NSLog(@"Next!");
    [delegate didSaveProfileInfo];
}

-(IBAction)didClickProfilePhoto:(id)sender {
    [self.stepButton setSelected:NO];
    [self didClickNext:sender];
}

@end
