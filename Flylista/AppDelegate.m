//
//  AppDelegate.m
//  Flylista
//
//  Created by Dmitry Shmidt on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitue [app_id] for your real Facebook app id).
#import "AppDelegate.h"
#import "AirportsListViewController.h"
@implementation AppDelegate
@synthesize window = _window;
//@synthesize facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Oslo"]];
    application.applicationIconBadgeNumber = 0;
    
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//    [GAI sharedInstance].dispatchInterval = 20;
//    // Optional: set debug to YES for extra debugging information.
//    [GAI sharedInstance].debug = YES;
//    // Create tracker instance.
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-8746647-9"];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        AirportsListViewController *airportsListViewController = ((UINavigationController *)splitViewController.viewControllers[0]).topViewController;
        airportsListViewController.delegate = (id)navigationController.topViewController;
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

#pragma mark - Notif
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    NSLog(@"Recieved Notification %@",notif);
}

@end
