//
//  AppDelegate.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=[UIColor whiteColor];
    
    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    self.window.rootViewController=navc;
    [self.window makeKeyAndVisible];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"WHITEcGFydG5lcl9pZD0wSUtqM1locE5CUWhIeFd4N0t5ckVjMXY2UjI5Y3dxV2pkOU0mc2lnPWU4NGRlZDk1MGY1ODNkNGVlYTlhMTc2ZWQ2ZDJmMTFmM2MwOTkyNzE6YWRtaW5JZD0xMzEmcm9sZT1taW5pJmV4cGlyZV90aW1lPTE1ODM4MzA1NjQmYWs9MElLajNZaHBOQlFoSHhXeDdLeXJFYzF2NlIyOWN3cVdqZDlNJmNyZWF0ZV90aW1lPTE1NTIyNzM2MTImbm9uY2U9MTU1MjI3MzYxMjE0NDAw" forKey:@"white-sdk-token"];
    // Override point for customization after application launch.
    return YES;
}

//设置横屏有关方法
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskLandscapeLeft;
        //| UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
