//
//  CreateProfileInfoViewController.m
//  Junction
//
//  Created by Bobby Ren on 1/27/13.
//
//

#import "CreateProfileInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface CreateProfileInfoViewController ()

@end

@implementation CreateProfileInfoViewController

@synthesize inputFields;
@synthesize userInfo;
@synthesize tableView;
@synthesize delegate;
@synthesize stepButton;
@synthesize scrollView;
@synthesize viewsForCell, viewsForHeader;

@synthesize privateLabel, privateSlider;
@synthesize lookingForCount, talkAboutCount;
@synthesize lookingForLastText, talkAboutLastText;

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
    self.viewsForHeader = [[NSMutableArray alloc] init];
    for (int i=0; i<15; i++) {
        [self.inputFields addObject:[NSNull null]];
        [self.viewsForCell addObject:[NSNull null]];
        [self.viewsForHeader addObject:[NSNull null]];
    }
    
    // get rid of bar
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.stepButton setSelected:YES]; // fake nav buttons
    CGRect frame = self.scrollView.frame;
    frame.size.height += 400;
    [self.scrollView setContentSize:frame.size];
    [self.scrollView setScrollEnabled:NO];
    //[self.scrollView setBackgroundColor:[UIColor blueColor]];
    
    frame = self.tableView.frame;
    frame.size.height += 200;
    [self.tableView setFrame:frame];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)populateWithUserInfo:(UserInfo*)newUserInfo {
    self.userInfo = newUserInfo;
    NSLog(@"Populating create profile page with userinfo: %x: %f %f", newUserInfo, newUserInfo.username, newUserInfo.email);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0 )
        return 100;
    return 40;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    if (section == 1)
        return 1;
    if (section == 2)
        return 1;
    return 0;
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"PERSONAL INFORMATION (No one can see this)";
    }
    else if (section == 1) {
        return @"Professional Information";
    }
    else if (section == 2) {
        return @"What are you looking for?";
    }
    return nil;
}
 */

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    int index;
    if (section == 0) {
        if ([self.viewsForHeader objectAtIndex:section] != [NSNull null]) {
            return [self.viewsForHeader objectAtIndex:section];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"PERSONAL INFORMATION"];
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 150, HEADER_HEIGHT)];
        [label2 setFont:[UIFont systemFontOfSize:11]];
        [label2 setTextColor:COLOR_LIGHTBLUE];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setTextAlignment:NSTextAlignmentLeft];
        [label2 setText:@"(No one can see this)"];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        [view addSubview:label2];
        [self.viewsForHeader replaceObjectAtIndex:section withObject:view];
        return [self.viewsForHeader objectAtIndex:section];    }
    else if (section == 1) {
        if ([self.viewsForHeader objectAtIndex:section] != [NSNull null]) {
            return [self.viewsForHeader objectAtIndex:section];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"WHAT ARE YOU LOOKING FOR?"];
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, HEADER_HEIGHT)];
        [label2 setFont:[UIFont systemFontOfSize:11]];
        [label2 setTextColor:COLOR_LIGHTBLUE];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setTextAlignment:NSTextAlignmentRight];
        [label2 setText:@"140"];
        self.lookingForCount = label2;
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        [view addSubview:label2];
        [self.viewsForHeader replaceObjectAtIndex:section withObject:view];
        return [self.viewsForHeader objectAtIndex:section];
    }
    else if (section == 2) {
        if ([self.viewsForHeader objectAtIndex:section] != [NSNull null]) {
            return [self.viewsForHeader objectAtIndex:section];
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"WHAT SHOULD OTHERS TALK TO YOU ABOUT?"];
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, HEADER_HEIGHT)];
        [label2 setFont:[UIFont systemFontOfSize:11]];
        [label2 setTextColor:COLOR_LIGHTBLUE];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setTextAlignment:NSTextAlignmentRight];
        [label2 setText:@"140"];
        self.talkAboutCount = label2;
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        [view addSubview:label2];
        [self.viewsForHeader replaceObjectAtIndex:section withObject:view];
        return [self.viewsForHeader objectAtIndex:section];
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
        UITextField * inputField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 250, ROW_HEIGHT)];
        [inputField setTextAlignment:NSTextAlignmentLeft];
        [inputField setFont:[UIFont boldSystemFontOfSize:15]];
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [inputField setDelegate:self];
        if (row == 0) {
            index = INPUT_NAME;
            //[label setText:@"NAME"];
            [inputField setPlaceholder:@"Your preferred name"];
            if (self.userInfo.username)
                [inputField setText:self.userInfo.username];
            [inputField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        else if (row == 1) {
            index = INPUT_EMAIL;
            //[label setText:@"EMAIL"];
            [inputField setPlaceholder:@"example@example.com"];
            if (self.userInfo.email)
                [inputField setText:self.userInfo.email];
            [inputField setKeyboardType:UIKeyboardTypeEmailAddress];
        }

        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ROW_HEIGHT)];
        //[view addSubview:label];
        [view addSubview:inputField];
        [self.viewsForCell replaceObjectAtIndex:index withObject:view];
        [inputFields replaceObjectAtIndex:index withObject:inputField];
        return [self.viewsForCell objectAtIndex:index];
    }
    else if (section == 1) {
        if (row == 0 && [self.viewsForCell objectAtIndex:INPUT_LOOKINGFOR] != [NSNull null]) {
            return [self.viewsForCell objectAtIndex:INPUT_LOOKINGFOR];
        }
        int index = INPUT_LOOKINGFOR;
        UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        [textView.layer setCornerRadius:5];
        [textView setFont:[UIFont boldSystemFontOfSize:15]];
        [textView setDelegate:self];
        textView.backgroundColor = [UIColor clearColor];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
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
    else if (section == 2) {
        if ([self.viewsForCell objectAtIndex:INPUT_TALKABOUT] != [NSNull null])
            return [self.viewsForCell objectAtIndex:INPUT_TALKABOUT];
        int index = INPUT_TALKABOUT;
        UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        [textView.layer setCornerRadius:5];
        [textView setFont:[UIFont boldSystemFontOfSize:15]];
        [textView setDelegate:self];
        textView.backgroundColor = [UIColor clearColor];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
        [view addSubview:textView];
        
        UIToolbar* keyboardDoneButtonView1 = [[UIToolbar alloc] init];
        keyboardDoneButtonView1.barStyle = UIBarStyleBlack;
        keyboardDoneButtonView1.translucent = YES;
        keyboardDoneButtonView1.tintColor = nil;
        [keyboardDoneButtonView1 sizeToFit];
        UIBarButtonItem* doneButton1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                        style:UIBarButtonItemStyleBordered target:self
                                                                       action:@selector(doneEditingTalkAbout)];
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
//    for (UIView * subview in cell.subviews)
//        [subview removeFromSuperview];
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
    CGRect frame = CGRectMake(0, index * ROW_HEIGHT-40, self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView scrollRectToVisible:frame animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // text field must also have delegate set as file's owner
	[textField resignFirstResponder];
    if (textField == [inputFields objectAtIndex:INPUT_NAME])
        [[inputFields objectAtIndex:INPUT_EMAIL] becomeFirstResponder];
    else if (textField == [inputFields objectAtIndex:INPUT_EMAIL])
        [[inputFields objectAtIndex:INPUT_LOOKINGFOR] becomeFirstResponder];
    
	return YES;
}

#pragma mark UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView == [inputFields objectAtIndex:INPUT_LOOKINGFOR])
        [self.scrollView scrollRectToVisible:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    else if (textView == [inputFields objectAtIndex:INPUT_TALKABOUT])
        [self.scrollView scrollRectToVisible:CGRectMake(0, 180, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    if (stopResponders) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
        return YES;
    }
    
    if (textView == [inputFields objectAtIndex:INPUT_LOOKINGFOR]) {
        [[inputFields objectAtIndex:INPUT_TALKABOUT] becomeFirstResponder];
    }
    else {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    int ct = [textView.text length];
    int left = 140 - ct;
    if (left < 0) {
        if (textView == [inputFields objectAtIndex:INPUT_LOOKINGFOR])
            textView.text = lookingForLastText;
        else if (textView == [inputFields objectAtIndex:INPUT_TALKABOUT])
            textView.text = talkAboutLastText;
    }
    else {
        if (textView == [inputFields objectAtIndex:INPUT_LOOKINGFOR]) {
            lookingForCount.text = [NSString stringWithFormat:@"%d", left];
            lookingForLastText = textView.text;
        }
        else if (textView == [inputFields objectAtIndex:INPUT_TALKABOUT]) {
            talkAboutCount.text = [NSString stringWithFormat:@"%d", left];
            talkAboutLastText = textView.text;
        }        
    }
}

-(void)doneEditingLookingFor {
    [self textViewShouldEndEditing:[inputFields objectAtIndex:INPUT_LOOKINGFOR]];
}
-(void)doneEditingTalkAbout {
    [self textViewShouldEndEditing:[inputFields objectAtIndex:INPUT_TALKABOUT]];
}

#pragma mark navigation

-(IBAction)didClickNext:(id)sender {
    NSLog(@"Next!");
    // copy back into userinfo if changed
    self.userInfo.username = ((UITextField*)[inputFields objectAtIndex:INPUT_NAME]).text;
    self.userInfo.email = ((UITextField*)[inputFields objectAtIndex:INPUT_EMAIL]).text;

    //self.userInfo.position = ((UITextField*)[inputFields objectAtIndex:INPUT_ROLE]).text;
    //self.userInfo.company = ((UITextField*)[inputFields objectAtIndex:INPUT_COMPANY]).text;
    //self.userInfo.industry = ((UITextField*)[inputFields objectAtIndex:INPUT_INDUSTRY]).text;
    
    self.userInfo.lookingFor = ((UITextView*)[inputFields objectAtIndex:INPUT_LOOKINGFOR]).text;
    self.userInfo.talkAbout = ((UITextView*)[inputFields objectAtIndex:INPUT_TALKABOUT]).text;
    
    // dismiss all input keyboards
    stopResponders = YES; // prevent other inputfields from becoming first responder
    for (int i=0; i<INPUT_MAX; i++) {
        [[inputFields objectAtIndex:i] resignFirstResponder];
    }
    
    [delegate didSaveProfileInfo];
}

-(IBAction)didClickProfilePhoto:(id)sender {
    [self.stepButton setSelected:NO];
    [self didClickNext:sender];
}

#pragma mark slider change
-(void)sliderDidChange:(id)sender {
    if ([self.privateSlider value] < .5) {
        [self.privateLabel setText:@"Private"];
    }
    else
        [self.privateLabel setText:@"Public"];
}

-(void)sliderDidClick:(id)sender {
    if ([self.privateSlider value] <= .5) {
        [self.privateSlider setValue:1];
    }
    else {
        [self.privateSlider setValue:0];
    }
    [self sliderDidChange:sender];
}

@end
