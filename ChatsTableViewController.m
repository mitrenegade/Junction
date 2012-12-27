//
//  ChatsTableViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import "ChatsTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ChatsTableViewController ()

@end

@implementation ChatsTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
        /*
        cell.textLabel.numberOfLines = 2;
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
         */
        /*
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 230, 12)];
        UILabel * commentTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 24, 230, 14)];
        UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 42, 230, 12)];
        
        nameLabel.textColor = [UIColor blackColor];
		nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		commentTextLabel.textColor = [UIColor blackColor];
		commentTextLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:14];
        [commentTextLabel setNumberOfLines:3];
		timeLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		timeLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [commentTextLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        */
        
        UIButton * photoView = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
		[photoView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photoView.layer setBorderWidth: 2.0];
        [photoView addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 10, 200, 50)];
        //textField.tag = TAG_TEXTFIELD;
        //photoView.tag = TAG_PHOTO;
        [cell.contentView addSubview:photoView];
        [cell.contentView addSubview:textField];
        [cell addSubview:cell.contentView];
    }

    // Configure the cell...
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
