//
//  ViewController.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/25.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "ViewController.h"




@interface initVCWindowController()
@end

@implementation initVCWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller’s window has been loaded from its nib file.
}
- (BOOL)windowShouldClose:(id)sender {
    [NSApp hide:nil];
    return NO;
}
@end




@implementation SetupViewController

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
        
        // 获取文件路径并设置准备写入
        NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
        NSURL *fileURL = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command")];
        NSURL *scriptURL = [tempDir URLByAppendingPathComponent:(@"Saves/setupScriptSavedForMac.txt")];

        // 询问执行前脚本
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Any additional command before running the script? eg: export proxy and select Xcode."];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"Cancel"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 200)];
            //  读取保存的脚本
            if ([[NSFileManager defaultManager] fileExistsAtPath:scriptURL.path isDirectory:false]) {
                NSString *scriptStringFromFileAtURL = [[NSString alloc]
                                                 initWithContentsOfURL:scriptURL
                                                 encoding:NSUTF8StringEncoding
                                                 error:NULL];
                [input setStringValue:scriptStringFromFileAtURL];
            }else{
                [input setStringValue:@""];
            }

        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        NSString *script = @"";
        if (button == NSAlertFirstButtonReturn) {
            script = [input stringValue];
        } else if (button == NSAlertSecondButtonReturn) {
            return;
        }
        
        // 如果执行前脚本存在
        BOOL havePreCommand = false;
        if (![script  isEqual: @""]) { havePreCommand = true;
            // 将脚本保存到本地
            [script writeToURL:scriptURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }
        
        // 更新 UI 进度条
        [_setupMacProgress setHidden:NO];
        [_setupMacProgress setDoubleValue:20];
        
        // 创建 GCD 队列 异步执行安装
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // 设置下载路径并写入文件
            NSString *stringURL = @"https://raw.githubusercontent.com/Co2333/coreBase/master/OneMonkey.sh";
            NSURL  *url = [NSURL URLWithString:stringURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                // 如果文件存在那么先删除
                if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:false]) {
                    NSLog(@"[!] Removing before download script.");
                    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
                }
                [urlData writeToURL:fileURL atomically:YES];
            }
            
            // 更新 UI 进度条
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_setupMacProgress setDoubleValue:50];
                });
            }];
            [task resume];

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
                // 将下载的脚本读入内存
                NSString *stringFromFileAtURL = [[NSString alloc]
                                                 initWithContentsOfURL:oldCommand
                                                 encoding:NSUTF8StringEncoding
                                                 error:NULL];
                // 合并脚本
                NSString *completedScript = script;
                completedScript = [completedScript stringByAppendingString:stringFromFileAtURL];
                // 写入执行前脚本
                [completedScript writeToURL:fileURL atomically:YES
                                   encoding:NSUTF8StringEncoding error:NULL];
                // 删除临时脚本
                [[NSFileManager defaultManager] removeItemAtURL:oldCommand error:NULL];
                
            } // if (havePreCommand)
            
            // 从fileURL执行脚本
            int returnVal = execCommandFromURL(fileURL);
            NSLog(@"[!] Exec command from URL returns:%d", returnVal);
            
            // 更新 UI 进度条
            NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_setupMacProgress setHidden:YES];
                    [self->_setupMacProgress setDoubleValue:0];
                });
            }];
            [task2 resume];

        });
        
        
    }
}
    // 开始设置iOS的环境
- (IBAction)startSetupForiOS:(id)sender {
}
    // 准备创建工程
- (IBAction)startCreateProject:(id)sender {
}



@end
