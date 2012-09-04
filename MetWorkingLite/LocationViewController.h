//
//  LocationViewController.h
//  CrowdDynamics
//
//  Created by Bobby Ren on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol LocationViewDelegate 
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
@end

@interface LocationViewController : UIViewController  <UIAccelerometerDelegate, CLLocationManagerDelegate >
{
    CLLocationManager *locationManager;
	UIAccelerometer *accelerometerManager;
    
	//NSObject<CLLocationManagerDelegate> *__unsafe_unretained locationDelegate;
	//NSObject<UIAccelerometerDelegate> *__unsafe_unretained accelerometerDelegate;
    NSObject<LocationViewDelegate> *__unsafe_unretained delegate;
}

@property (nonatomic, retain) UIAccelerometer *accelerometerManager;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, unsafe_unretained) NSObject<LocationViewDelegate> * delegate;
//@property (nonatomic, unsafe_unretained) NSObject<CLLocationManagerDelegate> * locationDelegate;
//@property (nonatomic, unsafe_unretained) NSObject<UIAccelerometerDelegate> * accelerometerDelegate;

// location manager stuff
- (void)startListening;

@end
