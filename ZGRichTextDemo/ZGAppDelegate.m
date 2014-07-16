//
//  ZGAppDelegate.m
//  ZGRichTextDemo
//
//  Created by mac on 14-7-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ZGAppDelegate.h"

#import "ZGRootViewController.h"

ZGAppDelegate *shareAppDelegateInstance;

@implementation ZGAppDelegate

@synthesize emotionDictionary;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSDictionary *emotionDicNew = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"emotion_en_new" ofType:@"plist"]];
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in emotionDicNew) {
        
        NSString *emotionFileName = [emotionDicNew objectForKey:key];
        
        UIImage *image = [UIImage imageNamed:emotionFileName];
        
        [tempDic setObject:image forKey:key];
        
        emotionFileName = nil;
        
        image           = nil;
    }
    emotionDictionary = tempDic;
    
    shareAppDelegateInstance = self;
    
    ZGRootViewController *rootVC = [[ZGRootViewController alloc] init];
    UINavigationController *rootNaivVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
//    rootVC = nil;
    
    self.window.rootViewController = rootNaivVC;
//    rootNaivVC = nil;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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

@end
