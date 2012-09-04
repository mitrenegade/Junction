//
//  LocationViewController.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"

@implementation LocationViewController

@synthesize locationManager, accelerometerManager;
@synthesize delegate;
//@synthesize accelerometerDelegate, locationDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // location accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        // heading accuracy
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		locationManager.headingFilter = kCLHeadingFilterNone;
		
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %@", [newLocation description]);
    [delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"Heading: %@", [newHeading description]);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
    [delegate locationError:error];
}

-(void)startListening {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

@end
