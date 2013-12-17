//
//  SettingsEditProfileViewController.m
//  Junction
//
//  Created by Bobby Ren on 4/6/13.
//
//

#import "SettingsEditProfileViewController.h"
#import "AppDelegate.h"
#import "SettingsEditPersonalViewController.h"
#import "SettingsEditGoalsViewController.h"
#import "SettingsEditBlurrinessViewController.h"
#import "SettingsProfessionalInfoViewController.h"
#import "UIImage+Resize.h"

static AppDelegate * appDelegate;

@interface SettingsEditProfileViewController ()

@end

@implementation SettingsEditProfileViewController

@synthesize lhHelper;
@synthesize shellUserInfo;

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
    titleView.text = @"Profile";
    UIFont * font = titleView.font;
    CGRect frame = CGRectMake(0, 0, [self.navigationItem.title sizeWithFont:font].width, 44);
    frame.origin.x = 320 - frame.size.width / 2;
    [titleView setFrame:frame];
    self.navigationItem.titleView = titleView;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon-back"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(10, 0, 30, 30)];
    [button addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:backbutton];
    self.view.backgroundColor = COLOR_FAINTBLUE;
    
    [photoView setImage:appDelegate.myUserInfo.photo];
    [photoView setImageURL:[NSURL URLWithString:appDelegate.myUserInfo.photoURL]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    int section = [indexPath section];
    int row = [indexPath row]; //[chatData count]-[indexPath row]-1;
    cell.accessoryView = self.accessoryRightArrow;
    switch (row) {
        case 0:
        {
            cell.textLabel.text = @"Personal";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Professional";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Goals";
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
    return HEADER_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextColor:COLOR_LIGHTBLUE];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"UPDATE INFORMATION"];
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, HEADER_HEIGHT)];
        [view addSubview:label];
        return view;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            NSLog(@"Personal");
            SettingsEditPersonalViewController * controller = [[SettingsEditPersonalViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:
        {
            NSLog(@"Professional");
            SettingsProfessionalInfoViewController * controller = [[SettingsProfessionalInfoViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:
        {
            NSLog(@"Goals");
            SettingsEditGoalsViewController * controller = [[SettingsEditGoalsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(IBAction)didClickPullFromLinkedIn:(id)sender {
    NSLog(@"Pull from linkedIn");
    
    if (self.lhHelper == nil) {
        self.lhHelper = [[LinkedInHelper alloc] init];
        self.lhHelper.delegate = self;
        
        [self.lhHelper loadCachedOAuth];
    }
    
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progress.labelText = @"Pulling from LinkedIn...";
    [self.lhHelper requestAllProfileInfoForID:appDelegate.myUserInfo.linkedInString];
}

-(IBAction)didClickButtonEditBlurriness:(id)sender {
    NSLog(@"Edit bluriness");
    SettingsEditBlurrinessViewController * controller = [[SettingsEditBlurrinessViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark changing photo
-(IBAction)didClickButtonChangePicture:(id)sender; {
    NSLog(@"Change picture");
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.navigationController.navigationBar.tintColor = [UIColor colorWithRed:23.0/255 green:153.0/255 blue:228.0/255 alpha:1];
    picker.allowsEditing = YES;
    
    [UIAlertView alertViewWithTitle:nil message:@"Where do you want to get your profile picture?" cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"Camera", @"Photo Album", nil] onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // regular res!
        }
        [self presentModalViewController:picker animated:YES];
    } onCancel:^{
        return;
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	UIImage * origImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage * editImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [photoView setImage:origImage];
    appDelegate.myUserInfo.photo = origImage;
    NSLog(@"Origimage: %f %f", origImage.size.width, origImage.size.height);
    NSLog(@"editImage: %f %f", editImage.size.width, editImage.size.height);
    if (editImage) {
        [photoView setImage:editImage];
        appDelegate.myUserInfo.photo = editImage;
    }
    
    // force to go into blur
    [self didClickButtonEditBlurriness:nil];
}

#pragma mark LinkedInHelperDelegate
-(void)linkedInDidFail:(NSError *)error {
    NSLog(@"Could not pull from linkedIn! Error: %@", error);
    progress.labelText = @"Error pulling your info!";
    progress.mode = MBProgressHUDModeCustomView;
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectZero];
    progress.customView = blankView;
    [progress hide:YES afterDelay:2];
}
-(void)linkedInParseProfileInformation:(NSDictionary*)profile {
    // returns the following information: first-name,last-name,industry,location:(name),specialties,summary,picture-url,email-address,educations,three-current-positions
    //NSString * userID = [profile objectForKey:@"pfUserID"];
    NSString * name = [[NSString alloc] initWithFormat:@"%@ %@",
                       [profile objectForKey:@"firstName"], [profile objectForKey:@"lastName"]];
    NSString * headline = [profile objectForKey:@"headline"];
    NSString * industry = [profile objectForKey:@"industry"];
    NSString * summary = [profile objectForKey:@"summary"];
    NSString * pictureUrl = [profile objectForKey:@"pictureUrl"];
    NSString * email = [profile objectForKey:@"emailAddress"];
    NSString * location = [[profile objectForKey:@"location"] objectForKey:@"name"]; // format: "location": {"name": loc}
    id _specialties = [profile objectForKey:@"specialties"];
    id _currentPositions = [profile objectForKey:@"positions"];
    NSArray * specialties = nil;
    NSArray * currentPositions = nil;
    if (_specialties && [_specialties isKindOfClass:[NSDictionary class]])
        specialties = [_specialties objectForKey:@"values"];
    if (_currentPositions && [_currentPositions isKindOfClass:[NSDictionary class]])
        currentPositions = [_currentPositions objectForKey:@"values"];
    
    self.shellUserInfo = [[UserInfo alloc] init];
    if (name)
        [shellUserInfo setUsername:name];
    if (headline)
        [shellUserInfo setHeadline:headline];
    if (industry)
        [shellUserInfo setIndustry:industry];
    if (summary)
        [shellUserInfo setSummary:summary];
    if (email)
        [shellUserInfo setEmail:email];
    if (location)
        [shellUserInfo setLocation:location];
    if (specialties)
        [shellUserInfo setSpecialties:specialties];
    if (currentPositions) {
        [shellUserInfo setCurrentPositions:currentPositions];
        id mostRecentPosition = [currentPositions objectAtIndex:0];
        id company = [mostRecentPosition objectForKey:@"company"];
        if ([company objectForKey:@"name"])
            [shellUserInfo setCompany:[company objectForKey:@"name"]];
        if ([company objectForKey:@"industry"]) // select current company's industry over personal industry
            [shellUserInfo setIndustry:[company objectForKey:@"industry"]];
        if ([mostRecentPosition objectForKey:@"title"])
            [shellUserInfo setPosition:[mostRecentPosition objectForKey:@"title"]];
    }
    
    // information not from linkedIn should be added to shellUser for display
    shellUserInfo.lookingFor = appDelegate.myUserInfo.lookingFor;
    shellUserInfo.talkAbout = appDelegate.myUserInfo.talkAbout;
    shellUserInfo.privacyLevel = appDelegate.myUserInfo.privacyLevel;
    
    if (pictureUrl) {
        NSLog(@"PictureURL: %@", pictureUrl);
        // if creating a new user and will go through profile process, must request photo
        [self requestOriginalLinkedInPhoto];
        // if logging in, request this photo but must get AWS photo later
    }
}

-(void)requestOriginalLinkedInPhoto {
    // load photo in background
    [self.lhHelper requestOriginalPhotoWithBlock:^(NSString * originalURL) {
        NSLog(@"Picture OriginalURL: %@", originalURL);
        shellUserInfo.photo = nil;
        shellUserInfo.photoBlur = nil;
        
        // upload unblurred photo to aws
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:originalURL]]];
            // resize
            CGSize frame = image.size;
            float scale = 1;
            if (frame.width < frame.height)
                scale = PROFILE_WIDTH / frame.width;
            else
                scale = PROFILE_HEIGHT / frame.height;
            CGSize target = frame;
            target.width *= scale;
            target.height *= scale;
            image = [image resizedImage:target interpolationQuality:kCGInterpolationHigh];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [progress hide:YES];
                
                // if we are creating a profile, first save this photo as unblurred
                shellUserInfo.photo = image;
                shellUserInfo.photoBlur = [appDelegate blurPhoto:image atPrivacyLevel:shellUserInfo.privacyLevel];
                PullFromLinkedInProfilePreviewController * controller = [[PullFromLinkedInProfilePreviewController alloc] init];
                [controller setDelegate:self];
                shellUserInfo.privacyLevel = appDelegate.myUserInfo.privacyLevel;
                [controller setUserInfo:shellUserInfo];

                [self.navigationController pushViewController:controller animated:YES];
            });
        });
    }];
}

-(void)didApprovePreview {
    // save shellUserInfo into myUserInfo
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progress.mode = MBProgressHUDModeCustomView;
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectZero];
    progress.customView = blankView;
    progress.labelText = @"Info updated from LinkedIn!";
    [progress hide:YES afterDelay:2];
    
    appDelegate.myUserInfo.username = shellUserInfo.username;
    appDelegate.myUserInfo.headline = shellUserInfo.headline;
    appDelegate.myUserInfo.industry = shellUserInfo.industry;
    appDelegate.myUserInfo.summary = shellUserInfo.summary;
    appDelegate.myUserInfo.email = shellUserInfo.email;
    appDelegate.myUserInfo.location = shellUserInfo.location;
    appDelegate.myUserInfo.company = shellUserInfo.company;
    appDelegate.myUserInfo.industry = shellUserInfo.industry;
    appDelegate.myUserInfo.position = shellUserInfo.position;
    
    [[appDelegate.myUserInfo toPFObject] save];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
