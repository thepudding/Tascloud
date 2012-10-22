//
//  ToDoCloudAppDelegate.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudAppDelegate.h"

@implementation ToDoCloudAppDelegate

NSString *archiveFilepath; 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    archiveFilepath = [documentsDirectory stringByAppendingPathComponent:@"todos"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:archiveFilepath])
    {
        // here, an archive already exists so we can populate a "people" array
        // of the above value objects
        
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:archiveFilepath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [(ToDoCloudViewController *)self.window.rootViewController restoreStateWith:unarchiver];
        [unarchiver finishDecoding];
        NSLog(@"Loaded: [%@]\nTo: %@", data, archiveFilepath);
    } else {
        // here, the archive didn't exist (first run), so instead, we just
        // create a blank array for "people" which can be populated in our app
    }
    
    // Override point for customization after application launch.
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
    NSMutableData *data;
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground
    if ([[NSFileManager defaultManager] fileExistsAtPath:archiveFilepath])
    {
        // here, an archive already exists so we can populate a "people" array
        // of the above value objects
        data = [[NSMutableData alloc] initWithContentsOfFile:archiveFilepath];
    } else {
        data = [[NSMutableData alloc] initWithLength:0];
    }
        
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [(ToDoCloudViewController *)self.window.rootViewController saveStateWith:archiver];
    [archiver finishEncoding];
    [data writeToFile:archiveFilepath atomically:YES];
    NSLog(@"Saved: [%@]\nTo: %@", data, archiveFilepath);
}

@end
