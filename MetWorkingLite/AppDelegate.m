//
//  AppDelegate.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 8/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
//@synthesize viewController = _viewController;
@synthesize myUserInfo;
@synthesize nav;
@synthesize lhHelper;
@synthesize proxController, profileController, mapViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //ViewController * viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //[viewController setDelegate:self];
    
    //self.viewController = viewController;
    
    myUserInfo = [[UserInfo alloc] init];
    
    UITabBarController * tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
    
    //locationViewController = [[LocationViewController alloc] init];
    //[locationViewController setDelegate:self];
    //[locationViewController startListening];    
    
    proxController = [[ProximityViewController alloc] init];
    [proxController setDelegate:self];
    
    mapViewController = [[MapViewController alloc] init];
    [mapViewController setDelegate:self];
    //[self.navigationController pushViewController:mapViewController animated:YES];
    
    profileController = [[ProfileViewController alloc] init];
    [profileController setDelegate:self];
    
	NSArray * viewControllers = [NSArray arrayWithObjects: proxController, mapViewController, profileController, nil];
    [tabBarController setViewControllers:viewControllers];
    
    //[self.view addSubview:tabBarController.view];
    nav = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    LoginViewController * loginController = [[LoginViewController alloc] init];
    [loginController setDelegate:self];
    //[nav pushViewController:loginController animated:YES];
    [loginController initializeWithUserInfo:myUserInfo];
    
    [nav presentModalViewController:loginController animated:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark LoginViewDelegate

-(void)didSelectUsername:(NSString *)username andEmail:(NSString *)email andPhoto:(UIImage *)photo {
    [myUserInfo setUsername:username];
    [myUserInfo setEmail:email];
    [myUserInfo setPhoto:photo];
    
    [nav dismissModalViewControllerAnimated:YES];
    
    // create fake users
    [proxController addUser:@"Steve Jobs" withTitle:@"Ghostly boss" withPhoto:nil atDistance:10];
}

-(void)didClickLinkedIn {
    lhHelper = [[LinkedInHelper alloc] init];
    [lhHelper setDelegate:self];
    UIViewController * lhView = [lhHelper loginView];
    [nav presentModalViewController:lhView animated:YES];
}

#pragma mark LinkedInHelperDelegate 

-(void)linkedInDidLoginWithUsername:(NSString *)username {
    [myUserInfo setUsername:username];
    [myUserInfo setEmail:nil];
    [myUserInfo setPhoto:nil];
}

#pragma mark ProximityDelegate and ProfileDelegate

-(UserInfo*)getMyUserInfo {
    return myUserInfo;
}
@end
