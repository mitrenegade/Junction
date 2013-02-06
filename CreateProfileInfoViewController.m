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
@synthesize scrollView;
@synthesize viewsForCell;

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
    self.viewsForCell = [[NSMutableArray alloc] init];
    for (int i=0; i<15; i++) {
        [self.inputFields addObject:[NSNull null]];
        [self.viewsForCell addObject:[NSNull null]];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.stepButton setSelected:YES]; // fake nav buttons
    CGRect frame = self.scrollView.frame;
    frame.size.height += 400;
    [self.scrollView setContentSize:frame.size];
    [self.scrollView setScrollEnabled:NO];
    //[self.scrollView setBackgroundColor:[UIColor blueColor]];
    /*
    frame = self.tableView.frame;
    frame.size.height += 200;
    [self.tableView setFrame:frame];
     */
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
        return 220;
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
    
    int index;
    if (section == 0) {
        if (row == 0 && [self.viewsForCell objectAtIndex:INPUT_NAME] != [NSNull null]) {
                return [self.viewsForCell objectAtIndex:INPUT_NAME];
        }
        if (row == 1 && [self.viewsForCell objectAtIndex:INPUT_EMAIL] != [NSNull null]) {
                return [self.viewsForCell objectAtIndex:INPUT_EMAIL];
        }
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        [label setBackgroundColor:[UIColor colorWithRed:165.0/255 green:211.0/255 blue:228.0/255 alpha:1]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, ROW_HEIGHT)];
        [inputField setTextAlignment:NSTextAlignmentLeft];
        [inputField setFont:[UIFont boldSystemFontOfSize:15]];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputField setDelegate:self];
        if (row == 0) {
            index = INPUT_NAME;
            [label setText:@"NAME"];
            [inputField setPlaceholder:@"Your preferred name"];
            if (self.userInfo.username)
                [inputField setText:self.userInfo.username];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 1) {
            index = INPUT_EMAIL;
            [label setText:@"EMAIL"];
            [inputField setPlaceholder:@"example@example.com"];
            if (self.userInfo.email)
                [inputField setText:self.userInfo.email];
            [inputField setKeyboardType:UIKeyboardTypeEmailAddress];
        }

        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ROW_HEIGHT)];
        [view addSubview:label];
        [view addSubview:inputField];
        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return [self.viewsForCell objectAtIndex:index];
    }
    else if (section == 1) {
        if (row == 0 && [self.viewsForCell objectAtIndex:INPUT_ROLE] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_ROLE];
        }
        if (row == 1 && [self.viewsForCell objectAtIndex:INPUT_COMPANY] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_COMPANY];
        }
        if (row == 2 && [self.viewsForCell objectAtIndex:INPUT_INDUSTRY] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_INDUSTRY];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, ROW_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        [label setBackgroundColor:[UIColor colorWithRed:165.0/255 green:211.0/255 blue:228.0/255 alpha:1]];
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(85, 0, 200, ROW_HEIGHT)];
        [inputField setTextAlignment:NSTextAlignmentLeft];
        [inputField setFont:[UIFont boldSystemFontOfSize:15]];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputField setDelegate:self];
        if (row == 0) {
            index = INPUT_ROLE;
            [label setText:@"ROLE"];
            [inputField setPlaceholder:@""];
            if (self.userInfo.position)
                [inputField setText:self.userInfo.position];
            else if (self.userInfo.headline)
                [inputField setText:self.userInfo.headline];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 1) {
            index = INPUT_COMPANY;
            [label setText:@"COMPANY"];
            [inputField setPlaceholder:@""];
            if (self.userInfo.company)
                [inputField setText:self.userInfo.company];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 2) {
            index = INPUT_INDUSTRY;
            [label setText:@"INDUSTRY"];
            [inputField setPlaceholder:@"optional"];
            if (self.userInfo.industry)
                [inputField setText:self.userInfo.industry];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ROW_HEIGHT)];
        [view addSubview:label];
        [view addSubview:inputField];
        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return [self.viewsForCell objectAtIndex:index];
    }
    else if (section == 2) {
        if ([self.viewsForCell objectAtIndex:INPUT_LOOKINGFOR] != [NSNull null])
            return [self.viewsForCell objectAtIndex:INPUT_LOOKINGFOR];
        int index = INPUT_LOOKINGFOR;
        UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        [textView.layer setCornerRadius:5];
        [textView setFont:[UIFont boldSystemFontOfSize:15]];
        [textView setDelegate:self];
        textView.backgroundColor = [UIColor clearColor];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ROW_HEIGHT)];
        [view addSubview:textView];
        
        UIToolbar* keyboardDoneButtonView1 = [[UIToolbar alloc] init];
        keyboardDoneButtonView1.barStyle = UIBarStyleBlack;
        keyboardDoneButtonView1.translucent = YES;
        keyboardDoneButtonView1.tintColor = nil;
        [keyboardDoneButtonView1 sizeToFit];
        UIBarButtonItem* doneButton1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                        style:UIBarButtonItemStyleBordered target:self
                                                                       action:@selector(doneEditingLookingFor)];
        [keyboardDoneButtonView1 setItems:[NSArray arrayWithObjects:doneButton1, nil]];
        textView.inputAccessoryView = keyboardDoneButtonView1;
        

        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        [inputFields replaceObjectAtIndex:index withObject:textView];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    int index;
    for (index = 0; index < [inputFields count]; index++) {
        if ([inputFields objectAtIndex:index] == textField)
            break;
    }
    CGRect frame = CGRectMake(0, index * ROW_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView scrollRectToVisible:frame animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == [inputFields objectAtIndex:INPUT_NAME])
        [[inputFields objectAtIndex:INPUT_EMAIL] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:INPUT_EMAIL])
        [[inputFields objectAtIndex:INPUT_ROLE] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:INPUT_ROLE])
        [[inputFields objectAtIndex:INPUT_COMPANY] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:INPUT_COMPANY])
        [[inputFields objectAtIndex:INPUT_INDUSTRY] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:INPUT_INDUSTRY])
        [[inputFields objectAtIndex:INPUT_LOOKINGFOR] becomeFirstResponder];
    
	return YES;
}

#pragma mark UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.scrollView scrollRectToVisible:CGRectMake(0, ROW_HEIGHT * INPUT_LOOKINGFOR + 50, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    return YES;
}

-(void)doneEditingLookingFor {
    [self textViewShouldEndEditing:[inputFields objectAtIndex:INPUT_LOOKINGFOR]];
}

#pragma mark navigation

-(IBAction)didClickNext:(id)sender {
    NSLog(@"Next!");
    // copy back into userinfo if changed
    self.userInfo.username = ((UITextField*)[inputFields objectAtIndex:INPUT_NAME]).text;
    self.userInfo.email = ((UITextField*)[inputFields objectAtIndex:INPUT_EMAIL]).text;
    self.userInfo.position = ((UITextField*)[inputFields objectAtIndex:INPUT_ROLE]).text;
    self.userInfo.company = ((UITextField*)[inputFields objectAtIndex:INPUT_COMPANY]).text;
    self.userInfo.industry = ((UITextField*)[inputFields objectAtIndex:INPUT_INDUSTRY]).text;
    [delegate didSaveProfileInfo];
}

-(IBAction)didClickProfilePhoto:(id)sender {
    [self.stepButton setSelected:NO];
    [self didClickNext:sender];
}

@end
