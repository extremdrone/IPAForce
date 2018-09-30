//
//  AppDelegate.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/25.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // 创建存档目录
    NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
    NSURL *savesDir = [tempDir URLByAppendingPathComponent:(@"Saves") isDirectory:true];
    BOOL fuckThis = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:savesDir.path isDirectory:&fuckThis]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:savesDir.path withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
