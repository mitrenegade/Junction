//
//  UserDescriptionViewController.m
//  Junction
//
//  Created by Bobby Ren on 12/19/12.
//
//

#import "UserDescriptionViewController.h"

@interface UserDescriptionViewController ()

@end

@implementation UserDescriptionViewController

@synthesize titleLabel, industryLabel, descriptionLabel;
@synthesize title, industry, description;

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
    [self refreshDescription];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshDescription {
    [self.titleLabel setText:self.title];
    [self.industryLabel setText:self.industry];
    [self.descriptionLabel setText:self.description];
}
@end
