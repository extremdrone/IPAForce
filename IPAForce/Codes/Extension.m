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
    /*
    struct stat sb;
    const char *path = [where path].absolutePath;
    stat(path, &sb);
    chmod(path, sb.st_mode | S_IXUSR);
    */
    // const char *Args = [[NSMutableString stringWithFormat:@"chmod u+x %@", where.path] UTF8String];
    // system(Args);
    const char *Args = [[NSMutableString stringWithFormat:@"chmod 0777 %@", where.path] UTF8String];
    system(Args);
    sleep(1);
    [[NSWorkspace sharedWorkspace] openURL:where];
    return 0;
}
