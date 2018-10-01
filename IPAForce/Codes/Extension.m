//
//  Extension.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/26.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "Extension.h"
#include <sys/stat.h>

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

// 获取命令行输出
NSString *getOutputOfThisCommand(NSString *command) {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", command,nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

// 检查系统状态

NSString *checkSystemStatus() {
    // init
    BOOL isReady = true;
    NSString *summaryString = @"Status Summary: ";
    NSString *summaryBody = @"";
    
    // Xcode Path
    NSString *XcodePath = getOutputOfThisCommand(@"xcode-select -p");
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
        isReady = false;
    }
    if (isFridaedMonkeyReady) {
        dependencyStatus = [dependencyStatus stringByAppendingString:@"\n- MonkeyDev & frida-dump ready"];
    }else{
        dependencyStatus = [dependencyStatus stringByAppendingString:@"\n- MonkeyDev & frida-dump is NOT ready"];
    }
    
    
    // 来看看是不是都装好了
    if (isReady) {
        summaryString = [summaryString stringByAppendingString:@"Ready\n"];
    }else{
        summaryString = [summaryString stringByAppendingString:@"Not Ready. Setup now!\n"];
    }
    
    // 是时候把他们放到一起了
    summaryString = [summaryString stringByAppendingString:XcodeSelectedPath];
    summaryString = [summaryString stringByAppendingString:dependencyStatus];
    
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
