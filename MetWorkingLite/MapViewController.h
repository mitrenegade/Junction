//
//  MapViewController.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@protocol MapViewDelegate <NSObject>

-(void)showUserSettings;

@end

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *_mapView;
@property (nonatomic, unsafe_unretained) id delegate;
@end
