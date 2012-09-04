//
//  ProximityViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProximityViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ProximityViewController ()

@end

@implementation ProximityViewController

@synthesize tableView;
@synthesize photoView, nameLabel, descLabel;
@synthesize names, titles, photos, distances;
@synthesize myUserInfo;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_friends"]];
//        [self.tabBarItem setTitle:@"Nearby"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    names = [[NSMutableArray alloc] init];
    titles = [[NSMutableArray alloc] init];
    photos = [[NSMutableArray alloc] init];
    distances = [[NSMutableArray alloc] init];
    
    [self setMyUserInfo:[delegate getMyUserInfo]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [nameLabel setText:myUserInfo.username];
    [photoView setImage:myUserInfo.photo];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addUser:(NSString *)name withTitle:(NSString *)title withPhoto:(UIImage *)photo atDistance:(double)distance {
    
    // todo: sort
    NSLog(@"Adding %@ at %f", name, distance);
    
    [names addObject:name];
    [titles addObject:title];
    if (photo)
        [photos addObject:photo];
    else 
        [photos addObject:[UIImage imageNamed:@"graphic_nopic"]];
    [distances addObject:[NSNumber numberWithDouble:distance]];
    
    [tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // may have more than one distance -> sections
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Really close by";
            break;
        
        case 1:
            return @"Within 100 feet";
            break;
            
        case 2:
            return @"Beyond 100 feet";
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Total rows: %d", [names count]);
    return [names count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] init];
        cell.selectedBackgroundView = [[UIImageView alloc] init];
        
		//cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setHighlightedTextColor:[cell.textLabel textColor]];
        cell.textLabel.numberOfLines = 1;
        UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(ROW_HEIGHT, 5, 170, 25)];
        UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(ROW_HEIGHT, 23, 170, 20)];
		topLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:102/255.0 green:0.0 blue:0.0 alpha:1.0];
		topLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont labelFontSize]-4];
		bottomLabel.textColor = [UIColor blackColor]; //[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		bottomLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize] - 7];
        
        UIButton * photo = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, ROW_HEIGHT-10, ROW_HEIGHT-10)];
		[photo.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [photo.layer setBorderWidth: 2.0];
        [photo addTarget:self action:@selector(didClickUserPhoto:) forControlEvents:UIControlEventTouchUpInside];
        photo.tag = PHOTO_TAG; // + [indexPath row];
        [cell.contentView addSubview:photo];
        
        //NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        topLabel.tag = TOP_LABEL_TAG;
        bottomLabel.tag = BOTTOM_LABEL_TAG;
        [cell.contentView addSubview:topLabel];
        [cell.contentView addSubview:bottomLabel];
        [cell addSubview:cell.contentView];
    }
    
    // Configure the cell...
    int section = [indexPath section];
    int index = [indexPath row];
    
    NSString * username;
    if (index >= [names count])
        [cell.textLabel setText:@"NIL"];
    else {
        UILabel * topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        UILabel * bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
        username = [names objectAtIndex:index];
        NSString * desc = [titles objectAtIndex:index];
        [topLabel setText:username];
        [bottomLabel setText:desc];
        [topLabel setFrame:CGRectMake(ROW_HEIGHT, 5, 170, 25)]; // bottom label exists so set topLabel higher

        UIImage * img = [photos objectAtIndex:index];
        UIButton * photo = (UIButton*)[cell viewWithTag:PHOTO_TAG]; // + index];
        //[photo setBackgroundImage:img forState:UIControlStateNormal]; //setImage:img forState:UIControlStateNormal];
        [photo setImage:img forState:UIControlStateNormal];
        photo.titleLabel.text = username;
        photo.titleLabel.hidden = YES;
    }    

    if (0) {
        UIImageView * addFriendButton = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 91, 30)];
        [addFriendButton setImage:[UIImage imageNamed:@"btn_follow"]];// forState:
        cell.accessoryView = addFriendButton;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;    
}


@end
