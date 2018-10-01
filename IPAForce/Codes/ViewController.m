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
    
    // 后台更新系统状态
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSString *summaryString = checkSystemStatus();
            // 回到主线程更新 UI
            NSURL *url;
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_sysStatusLabel setStringValue:summaryString];
                });
            }];
            [task resume];
        }
    });
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

    // 刷新系统状态
- (IBAction)refreshSysStatus:(id)sender {
    @autoreleasepool {
        NSString *summaryString = checkSystemStatus();
        NSURL *url;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                [self->_sysStatusLabel setStringValue:summaryString];
            });
        }];
        [task resume];
    }
}



    // 开始设置macOS的环境
- (IBAction)startSetupForMacOS:(id)sender {
    @autoreleasepool {
        
        // 获取文件路径并设置准备写入
        NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
        NSURL *fileURL = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command")];
        NSURL *scriptURL = [tempDir URLByAppendingPathComponent:(@"Saves/setupScriptSavedForMac.txt")];
        
        // 检查文件是否存在 不存在创建 存在检查是否为空 空则写入默认代理
        if (![[NSFileManager defaultManager] fileExistsAtPath:scriptURL.path]) {
            [@"export https_proxy=http://127.0.0.1:6152;\nexport http_proxy=http://127.0.0.1:6152;\nexport all_proxy=socks5://127.0.0.1:6153" writeToURL:scriptURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }

        // 询问执行前脚本
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Any additional command before running the script? eg: export proxy and select Xcode."];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"Cancel"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 200)];
        //  读取保存的脚本
        NSString *scriptStringFromFileAtURL = [[NSString alloc]
                                                 initWithContentsOfURL:scriptURL
                                                 encoding:NSUTF8StringEncoding
                                                 error:NULL];
        [input setStringValue:scriptStringFromFileAtURL];
        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        NSString *script = @"";
        if (button == NSAlertFirstButtonReturn) {
            script = [input stringValue];
            // 将脚本保存到本地
            [script writeToURL:scriptURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        } else if (button == NSAlertSecondButtonReturn) {
            return;
        }
        
        // 判断执行前脚本是否存在
        BOOL havePreCommand = false;
        if (![script  isEqual: @""]) { havePreCommand = true; }
        
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
                    NSLog(@"[!] Removing before download script");
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
                    NSString *summaryString = checkSystemStatus();
                    [self->_sysStatusLabel setStringValue:summaryString];
                });
            }];
            [task2 resume];

        });
        
        
    }
}
    // 开始设置iOS的环境
- (IBAction)startSetupForiOS:(id)sender {
    
    
    
}
    // 保存 ssh 密码
- (IBAction)startSeupSSH:(id)sender {

    // 先让 ssh 可以连接
    NSString *gradValue = [NSString alloc];
    NSString *iPGrabed = [NSString alloc];
    while (true) {
        // 检查 iP 是否有存档 准备数据
        NSURL *sshAddrSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshAddress.txt"];
        NSString *sshAddrString = [NSString alloc];
        if (![[NSFileManager defaultManager] fileExistsAtPath:sshAddrSave.path]) {
            sshAddrString = [[NSString alloc] initWithFormat:@"192.168.6.121:22"];
            [sshAddrString writeToURL:sshAddrSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }else{
            sshAddrString = [[NSString alloc] initWithContentsOfURL:sshAddrSave
                                                           encoding:NSUTF8StringEncoding
                                                              error:NULL];
        }
        int sshPortGrabed = 0;
        while (true) {
            // 获取用户输入 ssh 地址和端口
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Please tell me ssh address and port. No port means -p 22."];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"Cancel"];
            NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 150, 24)];
            [input setStringValue:sshAddrString];
            [alert setAccessoryView:input];
            NSInteger button = [alert runModal];
            NSString *inputString = @"";
            if (button == NSAlertFirstButtonReturn) {
                inputString = [input stringValue];
            } else if (button == NSAlertSecondButtonReturn) {
                return;
            }
            
            BOOL hasError = false;
            
            // 检查有没有屎在这数字里
            NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@":.0123456789"] invertedSet];
            if ([inputString rangeOfCharacterFromSet:set].location != NSNotFound) {
                NSLog(@"[Error] This string contains illegal characters");
                hasError = true;
            }
            
            // 检查是不是 iP 地址
            int ipQuads[5];
            const char *ipAddress = [inputString cStringUsingEncoding:NSUTF8StringEncoding];
            sscanf(ipAddress, "%d.%d.%d.%d:%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3], &ipQuads[4]);
            iPGrabed = [iPGrabed initWithFormat:@"%d.%d.%d.%d", ipQuads[0], ipQuads[1], ipQuads[2], ipQuads[3]];
            sshPortGrabed = ipQuads[4];
            @try {
                for (int quad = 0; quad < 4; quad++) {
                    if ((ipQuads[quad] < 0) || (ipQuads[quad] > 255)) {
                        NSException *ipException = [NSException
                                                    exceptionWithName:@"IPNotFormattedCorrectly"
                                                    reason:@"IP range is invalid"
                                                    userInfo:nil];
                        @throw ipException;
                    }
                }
            }
            @catch (NSException *exc) {
                NSLog(@"[ERROR] %@", [exc reason]);
                hasError = true;
            }
            
            // 判断有没有错误
            if (hasError) {
                NSAlert *errorAlert = [[NSAlert alloc] init];
                [errorAlert setMessageText:@"Not a iP address. Retry!"];
                [errorAlert addButtonWithTitle:@"Retry"];
                [errorAlert runModal];
            }else{
                gradValue = inputString;
                break;
            }
        }
        
        if (sshPortGrabed == 0) {
            sshPortGrabed = 22;
        }
        
        // 将数据写入存档
        [gradValue writeToURL:sshAddrSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        
        // 准备检查服务器连接性
        BOOL isConnectAble = ifOpenShellWorking(iPGrabed, sshPortGrabed);
        if (isConnectAble) {
            break;
        }
        NSAlert *errorAlert2 = [[NSAlert alloc] init];
        [errorAlert2 setMessageText:@"I can't connect to your iPhone. Retry!"];
        [errorAlert2 addButtonWithTitle:@"Retry"];
        [errorAlert2 runModal];
        // 暂时解决应用崩溃
        // [General] *** initialization method -initWithFormat:locale:arguments: cannot be sent to an abstract object of class __NSCFString: Create a concrete instance!
        return;
    }
    
    // 已经成功链接 ssh 询问密码
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Please tell me ssh password. !Notice that this is saved as the same as you input for now. Cancel it if you don't want to use this feature."];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 150, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    NSString *inputString = @"";
    if (button == NSAlertFirstButtonReturn) {
        inputString = [input stringValue];
    } else if (button == NSAlertSecondButtonReturn) {
        return;
    }
    NSURL *sshPassSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshPass.txt"];
    // 保存密码
    [inputString writeToURL:sshPassSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}
    
    
    // 准备创建工程
- (IBAction)startCreateProject:(id)sender {
}



@end
