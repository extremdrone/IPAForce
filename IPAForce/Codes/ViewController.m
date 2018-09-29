//
//  ViewController.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/25.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "ViewController.h"




@interface VCWindowController()
@end

@implementation VCWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller’s window has been loaded from its nib file.
}
- (BOOL)windowShouldClose:(id)sender {
    [NSApp hide:nil];
    return NO;
}
@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.parentViewController.view.wantsLayer = YES;
    self.parentViewController.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


    // 开始设置macOS的环境
- (IBAction)startSetupForMacOS:(id)sender {
    @autoreleasepool {

        // 询问执行前脚本
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Any additional command before running the script? eg: export proxy and select Xcode."];
        [alert addButtonWithTitle:@"Yes"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 200)];
        [input setStringValue:@""];
        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        NSString *script = @"";
        if (button == NSAlertFirstButtonReturn) {
            script = [input stringValue];
        } else if (button == NSAlertSecondButtonReturn) {
        }
        
        // 如果执行前脚本存在
        BOOL havePreCommand = false;
        if (![script  isEqual: @""]) {
            script = [NSString stringWithFormat:@"%@; ", script];
            havePreCommand = true;

        }
        
        // 获取文件路径并设置准备写入
        NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
        NSURL *fileURL = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command")];
        
        // 设置下载路径并写入文件
        NSString *stringURL = @"https://raw.githubusercontent.com/Co2333/coreBase/master/OneMonkey.sh";
        NSURL  *url = [NSURL URLWithString:stringURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            [urlData writeToURL:fileURL atomically:YES];
        }
        
        // 检查文件是否可读取
        NSError *error;
        if ([fileURL checkResourceIsReachableAndReturnError:&error]) {
            NSLog(@"[*] Download file at url completed. At path:%@", fileURL);
        } else {
            NSLog(@"[Error] Failed to download file at path:%@%@", fileURL, error);
        }
        
        // 如果执行前脚本存在那么创建新的脚本 如果不存在那么重命名脚本
        if (havePreCommand) {
            // 重命名下载的脚本
            NSURL *oldCommand = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command.tmp")];
            [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:oldCommand error:NULL];
            //将下载的脚本存入内存
            NSString *stringFromFileAtURL = [[NSString alloc]
                                             initWithContentsOfURL:oldCommand
                                             encoding:NSUTF8StringEncoding
                                             error:NULL];
            // 合并脚本
            NSString *completedScript = [NSMutableString stringWithFormat:@"#!/bin/bash \n%@\n%@", script, stringFromFileAtURL];
            // 写入执行前脚本
            [completedScript writeToURL:fileURL atomically:YES
                                encoding:NSUnicodeStringEncoding error:NULL];
            //删除临时脚本
            [[NSFileManager defaultManager] removeItemAtURL:oldCommand error:NULL];
            
        } // if (havePreCommand)
        
        // 从fileURL执行脚本
        int returnVal = execCommandFromURL(fileURL);
        NSLog(@"[!] Exec command from URL returns:%d", returnVal);
    }
}
    // 开始设置iOS的环境
- (IBAction)startSetupForiOS:(id)sender {
}
    // 准备创建工程
- (IBAction)startCreateProject:(id)sender {
}



@end
