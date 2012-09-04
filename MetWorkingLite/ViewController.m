//
//  ViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "ViewController.h"

@implementation ViewController

@synthesize locationViewController;
@synthesize mapViewController;
@synthesize delegate;

-(id)init {
    self = [super init];
    if (self) {
        [self.navigationItem setTitle:@"Main"];
        UIButton * settingsButton = [[UIButton alloc] init];
        [settingsButton setImage:[UIImage imageNamed:@"19-gear"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(didClickSettings:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
        [self.navigationItem setRightBarButtonItem:rightButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark LocationViewDelegate functions
- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text = [location description];
    
    CLLocationCoordinate2D zoomLocation;
    //zoomLocation.latitude = 39.281516;
    //zoomLocation.longitude= -76.580806;
    zoomLocation = [location coordinate];
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
}

#pragma mark navigationControllerDelegate
-(void)didClickSettings:(id)sender {
    [delegate showUserSettings];
}

-(void)showUserSettings {
    // passed on by MapViewController
    [delegate showUserSettings];
}


@end
