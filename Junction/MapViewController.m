//
//  MapViewController.m
//  CrowdDynamics
//
//  Created by Bobby Ren on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserPulse.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;
@synthesize delegate;
@synthesize lastPulseTimestamp;

BOOL didCenterOnUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"Map"];
        
        /*
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(didClickBackButton:)];
        [self.navigationItem setLeftBarButtonItem:leftButton];
         UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pin"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickCenterButton:)];
         [self.navigationItem setRightBarButtonItem:rightButton];
         */
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_world"]];
        //        [self.tabBarItem setTitle:@"Nearby"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //mapView = [[MKMapView alloc] initWithFrame: CGRectMake(10, 10, self.view.bounds.size.width-20, 290)];
    mapView.mapType = MKMapTypeHybrid;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    //mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    /*[mapView setScrollEnabled:NO];
     [mapView setZoomEnabled:NO];*/
    [mapView.layer setBorderColor: [[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0] CGColor]];
    [mapView.layer setBorderWidth: 5.0];
    [mapView.layer setCornerRadius:10.0f];
    [mapView.layer setMasksToBounds:YES];
    
    lastPulseTimestamp = nil;

    CLLocationCoordinate2D zoomLocation;
    //NSLog(@"%f", mapView.userLocation.location.coordinate.latitude);
    zoomLocation.latitude = 42.37;
    zoomLocation.longitude = -71.05;
    didCenterOnUser = NO;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.050*METERS_PER_MILE, 0.050*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];    
    
    if (self.mapView.userLocation && self.mapView.userLocation.coordinate.latitude >= -90.0 && self.mapView.userLocation.coordinate.latitude <= 90.0 && self.mapView.userLocation.coordinate.longitude >=-180.0 && self.mapView.userLocation.coordinate.longitude <= 180.0 && (self.mapView.userLocation.coordinate.latitude != 0 && self.mapView.userLocation.coordinate.longitude != 0)){
        zoomLocation.latitude = mapView.userLocation.location.coordinate.latitude;
        zoomLocation.longitude = mapView.userLocation.location.coordinate.longitude;
        
        viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        adjustedRegion = [mapView regionThatFits:viewRegion];    
    }
    [mapView setRegion:adjustedRegion animated:YES];
    
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setZoomRegion:(CLLocationCoordinate2D)zoomLocation {
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    [mapView setRegion:adjustedRegion animated:YES];      
}

#pragma mark MKMapViewDelegate
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Did update user location");
    if ( self.mapView.userLocation && self.mapView.userLocation.coordinate  .latitude > -90.0 && self.mapView.userLocation.coordinate.latitude < 90.0 &&self.mapView.userLocation.coordinate.longitude >-180.0 && self.mapView.userLocation.coordinate.longitude < 180.0 && (self.mapView.userLocation.coordinate.latitude != 0 && self.mapView.userLocation.coordinate.longitude != 0)) {  
        [self centerOnUser];
        mapView.showsUserLocation = YES;
    }
    
    if (!lastPulseTimestamp || [[NSDate date] timeIntervalSinceDate:lastPulseTimestamp] > USER_LOCATION_UPDATE_TIME) {
        CLLocation * myLocation = userLocation.location;
        UserInfo * myUserInfo = [delegate getMyUserInfo];
        NSLog(@"Updating user location via UserPulse: myUserInfo %@", myUserInfo);
        [UserPulse DoUserPulseWithLocation:myLocation forUser:myUserInfo];
        [self setLastPulseTimestamp:[NSDate date]];
    }
}

-(void)centerOnUser{
    if (didCenterOnUser) {
        NSLog(@"Already centered");
        return;
    }
    
    //NSLog(@"%f", self.mapView.userLocation.coordinate.latitude);
    if (self.mapView.userLocation && self.mapView.userLocation.coordinate.latitude > -90.0 && self.mapView.userLocation.coordinate.latitude < 90.0 && self.mapView.userLocation.coordinate.longitude >-180.0 && self.mapView.userLocation.coordinate.longitude < 180.0 && (self.mapView.userLocation.coordinate.latitude != 0 && self.mapView.userLocation.coordinate.longitude != 0)) {
        [self.mapView setCenterCoordinate:mapView.userLocation.coordinate animated:YES];
        //[self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];    
        [mapView setRegion:adjustedRegion animated:YES];
        didCenterOnUser = YES;
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}


#pragma mark NavigationControllerDelegate
-(void)didClickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didClickSettings:(id)sender {
//    [delegate showUserSettings];
}

-(IBAction)didClickCenterButton:(id)sender {
    didCenterOnUser = NO;
    [self centerOnUser];
}

@end
