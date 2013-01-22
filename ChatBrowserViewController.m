//
//  ChatBrowserViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import "ChatBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Chat.h"
#import "UIImage+GaussianBlur.h"

@interface ChatBrowserViewController ()

@end

@implementation ChatBrowserViewController

@synthesize recentChats;
@synthesize recentChatsArray;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateChats)
                                                 name:jnChatReceived
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateChats)
                                                 name:kNeedChatBrowserUpdate
                                               object:nil];
    
    [self updateChats];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:jnChatReceived
                                                  object:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [recentChats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView setUserInteractionEnabled:NO];
        photoView.tag = CB_TAG_PHOTO;
        
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 190, 15)];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        nameLabel.tag = CB_TAG_NAMELABEL;
        
        UITextView * textLabel = [[UITextView alloc] initWithFrame:CGRectMake(60, 25, self.tableView.frame.size.width - 45, 50)];
        [textLabel setUserInteractionEnabled:NO];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        [textLabel setScrollEnabled:NO];
        textLabel.tag = CB_TAG_TEXTLABEL;
        
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 100, 20)];
        timeLabel.tag = CB_TAG_TIMELABEL;
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        
        [cell.contentView addSubview:photoView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:timeLabel];
        
#if TESTING && 0
        [nameLabel setBackgroundColor:[UIColor redColor]];
        [photoView setBackgroundColor:[UIColor blueColor]];
        [textLabel setBackgroundColor:[UIColor greenColor]];
        [timeLabel setBackgroundColor:[UIColor redColor]];
#endif
    }
    
    NSUInteger row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    Chat * chat = [recentChatsArray objectAtIndex:row];
    
    if (row < recentChats.count){
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        UserInfo * userInfo = [[appDelegate allJunctionUserInfosDict] objectForKey:chat.sender];
        
        NSString *chatText = [chat message];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
        size.width = 190;
        //NSLog(@"Constrained textview size: %f %f", size.width, size.height);
        
        UIButton * photoView = (UIButton*)[cell.contentView viewWithTag:CB_TAG_PHOTO];
        if (chat.sender) {
            UIImage * image = userInfo.photo;
            if ([appDelegate isConnectedWithUser:userInfo])
                image = [image imageWithGaussianBlur];
            [photoView setImage:image forState:UIControlStateNormal];
            [photoView setFrame:CGRectMake(10, 10, 40, 40)];
        }
        else {
            NSLog(@"Invalid sender: %@!", [chat sender]);
        }
        
        UILabel * nameLabel = (UILabel*)[cell.contentView viewWithTag:CB_TAG_NAMELABEL];
        [nameLabel setText:@"Name hidden"];
        if ([appDelegate isConnectedWithUser:userInfo])
            nameLabel.text = userInfo.username;
        
        UITextView * textLabel = (UITextView*)[cell.contentView viewWithTag:CB_TAG_TEXTLABEL];
        textLabel.frame = CGRectMake(60, 25, size.width+10, size.height + 30);
        textLabel.font = font;
        textLabel.text = chatText;

        NSDate *theDate = [chat.pfObject createdAt];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm a"];
        UILabel * timeLabel = (UILabel*)[cell.contentView viewWithTag:CB_TAG_TIMELABEL];
        [timeLabel setFrame:CGRectMake(10, 55, 100, 20)];
        NSString *timeString = [formatter stringFromDate:theDate];
        UIFont * timeFont = [UIFont systemFontOfSize:11];
        [timeLabel setFont:timeFont];
        timeLabel.text = timeString;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    
    NSString *chatText = [[self.recentChatsArray objectAtIndex:row] message];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    CGSize size = [chatText sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    UITextView * tmp = [[UITextView alloc] initWithFrame:CGRectMake(60, 10, size.width+10, size.height + 30)];
    tmp.font = font;
    tmp.text = chatText;
    [tmp sizeToFit];
    CGRect frame = tmp.frame;
    
    float height = MAX(frame.origin.y + frame.size.height, 80);
    //NSLog(@"Height for cell %d: %f", row, height);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    Chat * chat = [recentChatsArray objectAtIndex:indexPath.row];
    NSString * sender = chat.sender;
    UserInfo * userInfo = [appDelegate getUserInfoWithID:sender];
    [appDelegate displayUserWithUserInfo:userInfo forChat:YES];
}

-(void)requestUpdateChats {
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    // todo: call function to get updated chats and reload allRecentChats
}

-(void)updateChats {
    if (!self.recentChatsArray) {
        self.recentChatsArray = [[NSMutableArray alloc] init];
    }
    [self.recentChatsArray removeAllObjects];
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.recentChats = appDelegate.allRecentChats; // just a pointer
    [self.recentChatsArray addObjectsFromArray:[[self.recentChats objectEnumerator] allObjects]];
    NSLog(@"Recent chats: %d", [self.recentChatsArray count]);
    [self.tableView reloadData];
}


@end