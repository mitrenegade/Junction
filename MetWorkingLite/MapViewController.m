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
#import "ParseLocationAnnotation.h"
#import "AppDelegate.h"
#import "ParseLocationAnnotation.h"
#import "MapGestureRecognizer.h"
#import "Annotation.h"
@interface MapViewController ()

@end

@implementation MapViewController
@synthesize myMapView;
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
    //myMapView = [[MKMapView alloc] initWithFrame: CGRectMake(10, 10, self.view.bounds.size.width-20, 290)];
    myMapView.mapType = MKMapTypeHybrid;
    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    //myMapView.userTrackingMode = MKUserTrackingModeFollow;
    
    /*[myMapView setScrollEnabled:NO];
     [myMapView setZoomEnabled:NO];*/
    [myMapView.layer setBorderColor: [[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0] CGColor]];
    [myMapView.layer setBorderWidth: 5.0];
    [myMapView.layer setCornerRadius:10.0f];
    [myMapView.layer setMasksToBounds:YES];
    
    lastPulseTimestamp = nil;

    MapGestureRecognizer *tapGesture = [[MapGestureRecognizer alloc] initWithTarget:self action:@selector(mapInteractionDidOccur)];
    tapGesture.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self mapInteractionDidOccur];
    };
    [myMapView addGestureRecognizer:tapGesture];

    CLLocationCoordinate2D zoomLocation;
    //NSLog(@"%f", myMapView.userLocation.location.coordinate.latitude);
    zoomLocation.latitude = 42.37;
    zoomLocation.longitude = -71.05;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.050*METERS_PER_MILE, 0.050*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [myMapView regionThatFits:viewRegion];    
    
    if (self.myMapView.userLocation && self.myMapView.userLocation.coordinate.latitude >= -90.0 && self.myMapView.userLocation.coordinate.latitude <= 90.0 && self.myMapView.userLocation.coordinate.longitude >=-180.0 && self.myMapView.userLocation.coordinate.longitude <= 180.0 && (self.myMapView.userLocation.coordinate.latitude != 0 && self.myMapView.userLocation.coordinate.longitude != 0)){
        zoomLocation.latitude = myMapView.userLocation.location.coordinate.latitude;
        zoomLocation.longitude = myMapView.userLocation.location.coordinate.longitude;
        
        viewRegion = MKCoordinateRegionMakeWithDistance(self.myMapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        adjustedRegion = [myMapView regionThatFits:viewRegion];    
    }
    [myMapView setRegion:adjustedRegion animated:YES];
    
    [self.view addSubview:myMapView];
    [self centerOnUser];
    myMapView.showsUserLocation = YES;
    didDragMap = NO;
    didUpdateUserLocation = NO;
}

- (void)viewDidUnload
{
    [self setMyMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self centerOnUser];
    [self reloadAll];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setZoomRegion:(CLLocationCoordinate2D)zoomLocation {
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [myMapView regionThatFits:viewRegion];                
    // 4
    [myMapView setRegion:adjustedRegion animated:YES];      
}

-(void) mapInteractionDidOccur{
    didDragMap = YES;
}

#pragma mark MKMapViewDelegate
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"Did update user location with accuracy %f", userLocation.location.horizontalAccuracy);
    if ( self.myMapView.userLocation && self.myMapView.userLocation.coordinate.latitude > -90.0 && self.myMapView.userLocation.coordinate.latitude < 90.0 &&self.myMapView.userLocation.coordinate.longitude >-180.0 && self.myMapView.userLocation.coordinate.longitude < 180.0 && (self.myMapView.userLocation.coordinate.latitude != 0 && self.myMapView.userLocation.coordinate.longitude != 0)) {
    
        // todo: need to only do this if our accuracy is very bad
        [self centerOnUser];
        myMapView.showsUserLocation = YES;
    }
    double elapsed = [[NSDate date] timeIntervalSinceDate:lastPulseTimestamp];
    NSLog(@"%f seconds elapsed since last pulse at %@", elapsed, lastPulseTimestamp );
    if (!lastPulseTimestamp || elapsed > USER_LOCATION_UPDATE_TIME) {
        [self setLastPulseTimestamp:[NSDate date]];
        CLLocation * myLocation = userLocation.location;
        UserInfo * myUserInfo = [delegate getMyUserInfo];
        NSLog(@"Updating user location via UserPulse: myUserInfo %@", myUserInfo);
        [UserPulse DoUserPulseWithLocation:myLocation forUser:myUserInfo];
    }
}

-(void)centerOnUser{
    //NSLog(@"%f", self.myMapView.userLocation.coordinate.latitude);
    if (didDragMap && didUpdateUserLocation)
        return;
    if (didUpdateUserLocation)
        return;
    if (self.myMapView.userLocation && self.myMapView.userLocation.coordinate.latitude > -90.0 && self.myMapView.userLocation.coordinate.latitude < 90.0 && self.myMapView.userLocation.coordinate.longitude >-180.0 && self.myMapView.userLocation.coordinate.longitude < 180.0 && (self.myMapView.userLocation.coordinate.latitude != 0 && self.myMapView.userLocation.coordinate.longitude != 0)) {
        [self.myMapView setCenterCoordinate:myMapView.userLocation.coordinate animated:YES];
        //[self.myMapView.userLocation removeObserver:self forKeyPath:@"location"];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.myMapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        MKCoordinateRegion adjustedRegion = [myMapView regionThatFits:viewRegion];    
        [myMapView setRegion:adjustedRegion animated:YES];
        didUpdateUserLocation = YES;
   }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
#if 1
    if ([annotation isKindOfClass:[ParseLocationAnnotation class]]) {
        static NSString *identifier = @"PulseAnnotationPin";
        ParseLocationAnnotation *location = (ParseLocationAnnotation *) annotation;
        
        MKPinAnnotationView * annotationView = (MKPinAnnotationView *) [myMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else {
            annotationView.annotation = annotation;
        }
        /*
        UIImage *image = [UIImage imageNamed: @"pin"];
        annotationView.image = image;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [annotationView addSubview:imageView];
         */
		annotationView.pinColor = MKPinAnnotationColorRed;
		annotationView.animatesDrop = YES;
        annotationView.annotation = location;
        annotationView.draggable = NO;
        annotationView.enabled = YES;
        //annotationView.canShowCallout = YES;
        annotationView.selected = YES;
        NSLog(@"Annotation drawn at location %f %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
        return annotationView;
    }
#else
    if ([annotation isKindOfClass:[ParseLocationAnnotation class]]) {
        static NSString *identifier = @"PulseAnnotationPin";
        Annotation *location = (Annotation *) annotation;
        
        MKAnnotationView * annotationView = (MKAnnotationView *) [myMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else {
            annotationView.annotation = annotation;
        }
        
        UIImage *image = [UIImage imageNamed: @"pin"];
        annotationView.image = image;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [annotationView addSubview:imageView];
        annotationView.annotation = location;
        annotationView.draggable = YES;
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        annotationView.selected = YES;
        NSLog(@"Annotation drawn at location %f %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
        return annotationView;
    }
#endif
    return nil;
}

#pragma mark NavigationControllerDelegate
-(void)didClickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didClickSettings:(id)sender {
//    [delegate showUserSettings];
}

-(void)reloadAll {
    NSLog(@"***Reloading all in mapView!***");
    [myMapView removeAnnotations:[myMapView annotations]];
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray * allUserInfos = [appDelegate allJunctionUserInfos];
    NSMutableDictionary * allPulses = [appDelegate allPulses];
    NSMutableArray * newAnnotations = [[NSMutableArray alloc] init];
    for (UserInfo * friendUserInfo in allUserInfos) {
        NSString * userID = friendUserInfo.pfUserID;
        UserPulse * pulse = [allPulses objectForKey:userID];
        NSLog(@"Getting pulse for user %@ %@ = %f %f", friendUserInfo.username, userID, pulse.coordinate.latitude, pulse.coordinate.longitude);
        ParseLocationAnnotation * annotation = [[ParseLocationAnnotation alloc] initWithCoordinate:pulse.coordinate];//[pulse toAnnotation];
        if (!annotation) {
            NSLog(@"No annotation!");
        }
        else {
            [newAnnotations addObject:annotation];
            /*
            for (float x = -.1; x < .11; x+=.01) {
                CLLocationCoordinate2D newCoord = pulse.coordinate;
                newCoord.latitude += x;
                ParseLocationAnnotation * annotation2 = [[ParseLocationAnnotation alloc] initWithCoordinate:newCoord];//[[pulse toAnnotation] copy];
                [annotation2 setCoordinate:newCoord];
                [newAnnotations addObject:annotation2];
            }
             */
        }
    }
    NSLog(@"Adding %d new annotations!", [newAnnotations count]);
    if ([newAnnotations count] > 0) {
        [myMapView addAnnotations:newAnnotations];
    }

}



@end
