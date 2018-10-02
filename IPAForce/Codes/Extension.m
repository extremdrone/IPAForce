//
//  Extension.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/26.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "Extension.h"
#include <sys/stat.h>


NSString *replaceCharacterAtInextWithLenthAndWhat(NSString* whoTo, int whereToHave, int howlong, NSString* wahtTo){
    return [whoTo stringByReplacingCharactersInRange:NSMakeRange(whereToHave, howlong) withString:wahtTo];
}

int execCommandFromURL(NSURL *where) {
    
    // 给文件可执权限
    const char *Args = [[NSMutableString stringWithFormat:@"chmod 0777 %@", where.path] UTF8String];
    system(Args);
    
    // 执行脚本
    [[NSWorkspace sharedWorkspace] openURL:where];
    return 0;
    
    /*
    struct stat sb;
    const char *path = [where path].absolutePath;
    stat(path, &sb);
    chmod(path, sb.st_mode | S_IXUSR);
    */
    // const char *Args = [[NSMutableString stringWithFormat:@"chmod u+x %@", where.path] UTF8String];
    // system(Args);
}

// 检查 ssh 地址和端口是否正确
BOOL ifOpenShellWorking(NSString *whereToCheck, int portNumber) {
    // export $SSHADDR=com.lakr.IPAForce.PRESET.sshaddr
    // export $SSHPORT=com.lakr.IPAForce.PRESET.sshport
    NSString *sshAddr = [[NSString alloc] initWithFormat:@"export SSHADDR=%@", whereToCheck];
    NSString *sshPort = [[NSString alloc] initWithFormat:@"export SSHPORT=%d", portNumber];
    // 获取脚本文件
    NSString *bashScriptPathFromApp = [[[NSBundle mainBundle] resourcePath]
                                     stringByAppendingPathComponent:@"checkServerAvailable.sh"];
    // 读取文件
    NSError *error;
    NSURL *fileTmp = [[NSURL alloc] initFileURLWithPath:bashScriptPathFromApp];
    NSString *readFromScriptFile = [[NSString alloc]
                                    initWithContentsOfURL:fileTmp
                                    encoding:NSUTF8StringEncoding
                                    error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    // 创建脚本放到 App 文档目录
    NSString *script = [[NSString alloc] initWithFormat:@"#!/bin/sh\n%@\n%@\n%@\n", sshAddr, sshPort, readFromScriptFile];
    
    // 检测脚本是否存在
    NSURL *scriptInDocPath = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"checkServerAvailable.sh"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:scriptInDocPath.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:scriptInDocPath.path error:NULL];
    }
    [script writeToURL:scriptInDocPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    // 创建命令行脚本并执行
    NSString *readyToRunTask = [[NSString alloc] initWithFormat:@"sh %@", scriptInDocPath.path];
    NSString *retVal = getOutputOfThisCommand(readyToRunTask, 5);
    // retVal    __NSCFString *    @"[*] Servers available.\n"    0x0000600000c80450
    // retVal    __NSCFString *    @"[Error] Servers not available.\n"    0x00006000017c4f00
    if ([retVal  isEqual: @"[*] Servers available.\n"]) {
        return YES;
    }
    return NO;
}


// 获取命令行输出
NSString *getOutputOfThisCommand(NSString *command, double timeOut) {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", command,nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // 1 minute timeout
    NSDate *terminateDate = [[NSDate date] dateByAddingTimeInterval:timeOut];
    while ((task != nil) && ([task isRunning]))   {
        if ([[NSDate date] compare:(id)terminateDate] == NSOrderedDescending)   {
            NSLog(@"Error: terminating task, timeout was reached.");
            [task terminate];
        }
        [NSThread sleepForTimeInterval:1.0];
    }

    return result;
}

// 检查系统状态
NSString *checkSystemStatus() {
    // init
    sleep(1);
    BOOL isReady = true;
    NSString *summaryString = @"Status Summary: ";
    NSString *summaryBody = @"";
    NSString *tips = @"";
    
    // Xcode Path
    NSString *XcodePath = getOutputOfThisCommand(@"xcode-select -p", 1);
    XcodePath = [XcodePath substringToIndex:[XcodePath length] - 20];
    NSString *XcodeSelectedPath = @"\n- Xcode selected at path: ";
    XcodeSelectedPath = [XcodeSelectedPath stringByAppendingString:XcodePath];
    summaryBody = [summaryBody stringByAppendingString:XcodeSelectedPath];
    
    // 获取这个 Xcode 的版本号
    // Help wanted. Orz....
    
    // 检查依赖文件
    BOOL isFridaedMonkeyReady= true;
    NSString *unInstalledDependenciesData = @"";
    // 顺序检查 brew wget ldid ldid2 dpkg libimobiledevice class-dump jtool jtool2 joker
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/brew"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"HomeBrew, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/wget"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"wget, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/ldid"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"ldid, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/ldid2"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"ldid2, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/dpkg"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"dpkg, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/iproxy"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"libimobiledevice, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/frida-ps"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"frida-server, "];
        isFridaedMonkeyReady = false;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/opt/MonkeyDev"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"MonkeyDev, "];
        isFridaedMonkeyReady = false;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/class-dump"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"class-dump, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/jtool"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"jtool, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/jtool2"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"jtool2, "];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSURL URLWithString:@"/usr/local/bin/joker"].path isDirectory:false]) {
        unInstalledDependenciesData = [unInstalledDependenciesData stringByAppendingString:@"joker, "];
    }
    
    NSString *dependencyStatus = @"\n- macOS essential dependency installed";
    if (![unInstalledDependenciesData isEqualToString:@""]) {
        NSString *tmpSt = [unInstalledDependenciesData substringToIndex:[unInstalledDependenciesData length] - 2];
        dependencyStatus = @"\n- macOS essential dependency [";
        dependencyStatus = [dependencyStatus stringByAppendingString:tmpSt];
        dependencyStatus = [dependencyStatus stringByAppendingString:@"] not installed."];
        tips = @"****** Orz You may want to run Setup macOS\n\n";
        isReady = false;
    }
    if (isFridaedMonkeyReady) {
        dependencyStatus = [dependencyStatus stringByAppendingString:@"\n- MonkeyDev & frida-dump ready"];
    }else{
        dependencyStatus = [dependencyStatus stringByAppendingString:@"\n- MonkeyDev & frida-dump is NOT ready"];
        tips = @"****** Orz You may want to run Setup macOS\n\n";
    }
    
    // 检查 ssh 连接性
    NSString *sshCheck = @"\n- iOS root ssh connect is not established";
    NSURL *sshAddrSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshAddress.txt"];
    NSURL *sshPassSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshPass.txt"];
    NSString *inputString = [[NSString alloc] initWithContentsOfFile:sshAddrSave.path
                                                            encoding:NSUTF8StringEncoding
                                                               error:NULL];
    NSString *inputStringPass = [[NSString alloc] initWithContentsOfFile:sshPassSave.path
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
    int ipQuads[5];
    const char *ipAddress = [inputString cStringUsingEncoding:NSUTF8StringEncoding];
    sscanf(ipAddress, "%d.%d.%d.%d:%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3], &ipQuads[4]);
    NSString *iPGrabed = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", ipQuads[0], ipQuads[1], ipQuads[2], ipQuads[3]];
    int sshPortGrabed = ipQuads[4];
    NMSSHSession *session = [NMSSHSession connectToHost:iPGrabed port:sshPortGrabed withUsername:@"root"];
    BOOL sshConnectedFlag = false;
    if (session.isConnected) {
        [session authenticateByPassword:inputStringPass];
        if (session.isAuthorized) {
            sshCheck = @"\n- iOS root ssh connect established";
            sshConnectedFlag = true;
        }
    }
    if (!sshConnectedFlag) {
        isReady = false;
        tips = @"****** Orz You may want to run Setup SSH\n\n";
    }
    [session disconnect];
    
    // 来看看是不是都装好了
    if (isReady) {
        summaryString = [summaryString stringByAppendingString:@"Ready\n\n"];
        tips = @"****** 666 You may want to begin with Start Coding\n";
    }else{
        summaryString = [summaryString stringByAppendingString:@"Not Ready. Setup now!\n"];
    }
    
    // 是时候把他们放到一起了
    summaryString = [summaryString stringByAppendingString:tips];
    summaryString = [summaryString stringByAppendingString:XcodeSelectedPath];
    summaryString = [summaryString stringByAppendingString:dependencyStatus];
    summaryString = [summaryString stringByAppendingString:sshCheck];
    
    /* 标签结构
     Status Summary: Ready
     
     - Xcode selected at path: /Applications⁩/Xcode.app      |
     - Xcode Version 10.0 (10A254a)
     - macOS essential dependency installed                 |
     - MonkeyDev & frida-dump ready
     - iOS root ssh connect established
     - iOS essential dependency installed
     - iOS frida-server running
     */
    
    return summaryString;
}
