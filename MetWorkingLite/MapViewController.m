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
@synthesize _mapView;
@synthesize delegate;
@synthesize lastPulseTimestamp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"Map"];
        
        /*
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(didClickBackButton:)];
        [self.navigationItem setLeftBarButtonItem:leftButton];
         */
        
        /*
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickSettings:)];
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
    //_mapView = [[MKMapView alloc] initWithFrame: CGRectMake(10, 10, self.view.bounds.size.width-20, 290)];
    _mapView.mapType = MKMapTypeHybrid;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    //_mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    /*[_mapView setScrollEnabled:NO];
     [_mapView setZoomEnabled:NO];*/
    [_mapView.layer setBorderColor: [[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0] CGColor]];
    [_mapView.layer setBorderWidth: 5.0];
    [_mapView.layer setCornerRadius:10.0f];
    [_mapView.layer setMasksToBounds:YES];
    
    lastPulseTimestamp = nil;

    CLLocationCoordinate2D zoomLocation;
    //NSLog(@"%f", _mapView.userLocation.location.coordinate.latitude);
    zoomLocation.latitude = 42.37;
    zoomLocation.longitude = -71.05;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.050*METERS_PER_MILE, 0.050*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];    
    
    if (self._mapView.userLocation && self._mapView.userLocation.coordinate.latitude >= -90.0 && self._mapView.userLocation.coordinate.latitude <= 90.0 && self._mapView.userLocation.coordinate.longitude >=-180.0 && self._mapView.userLocation.coordinate.longitude <= 180.0 && (self._mapView.userLocation.coordinate.latitude != 0 && self._mapView.userLocation.coordinate.longitude != 0)){
        zoomLocation.latitude = _mapView.userLocation.location.coordinate.latitude;
        zoomLocation.longitude = _mapView.userLocation.location.coordinate.longitude;
        
        viewRegion = MKCoordinateRegionMakeWithDistance(self._mapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        adjustedRegion = [_mapView regionThatFits:viewRegion];    
    }
    [_mapView setRegion:adjustedRegion animated:YES];
    
    [self.view addSubview:_mapView];
    
}

- (void)viewDidUnload
{
    [self set_mapView:nil];
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
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];                
    // 4
    [_mapView setRegion:adjustedRegion animated:YES];      
}

#pragma mark MKMapViewDelegate
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Did update user location");
    if ( self._mapView.userLocation && self._mapView.userLocation.coordinate  .latitude > -90.0 && self._mapView.userLocation.coordinate.latitude < 90.0 &&self._mapView.userLocation.coordinate.longitude >-180.0 && self._mapView.userLocation.coordinate.longitude < 180.0 && (self._mapView.userLocation.coordinate.latitude != 0 && self._mapView.userLocation.coordinate.longitude != 0)) {  
        [self centerOnUser];
        _mapView.showsUserLocation = YES;
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
    //NSLog(@"%f", self._mapView.userLocation.coordinate.latitude);
    if (self._mapView.userLocation && self._mapView.userLocation.coordinate.latitude > -90.0 && self._mapView.userLocation.coordinate.latitude < 90.0 && self._mapView.userLocation.coordinate.longitude >-180.0 && self._mapView.userLocation.coordinate.longitude < 180.0 && (self._mapView.userLocation.coordinate.latitude != 0 && self._mapView.userLocation.coordinate.longitude != 0)) {
        [self._mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
        //[self._mapView.userLocation removeObserver:self forKeyPath:@"location"];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self._mapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];    
        [_mapView setRegion:adjustedRegion animated:YES];
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

@end
