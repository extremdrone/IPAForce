//
//  Extension.h
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/26.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#ifndef Extension_h
#define Extension_h


#endif /* Extension_h */


#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>

int execCommandFromURL(NSURL *where);
NSString *getOutputOfThisCommand(NSString *command, int timeOut);
NSString *checkSystemStatus(void);
BOOL ifOpenShellWorking(NSString *whereToCheck, int portNumber);
