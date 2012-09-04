//
//  ViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LocationViewController.h"
#import "MapViewController.h"
#import "ProximityViewController.h"

@protocol ViewControllerDelegate <NSObject>

-(void)showUserSettings;

@end

@interface ViewController : UIViewController <MapViewDelegate, LocationViewDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate>
{
    IBOutlet UILabel *locationLabel;
    UITabBarController * tabBarController;
}

@property (nonatomic) LocationViewController * locationViewController;
@property (nonatomic) MapViewController * mapViewController;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, retain) UITabBarController * tabBarController;
- (void)signInToCustomService;

@end
