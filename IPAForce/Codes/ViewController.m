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
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Any additional command before running the script?"];
    [alert addButtonWithTitle:@"Yes"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
    [input setStringValue:@""];
    
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    NSString *script = @"";
    if (button == NSAlertFirstButtonReturn) {
        script = [input stringValue];
    } else if (button == NSAlertSecondButtonReturn) {
    }
    
    if (![script  isEqual: @""]) {
        script = [NSString stringWithFormat:@"%@; ", script];
    }
    
    NSString *s = [NSString stringWithFormat:
                   @"tell application \"Terminal\" to do script \""];
    NSString *concat = [NSString stringWithFormat: @"%@%@ curl -o ~/Downloads/OneMonkey.sh 'https://raw.githubusercontent.com/Co2333/coreBase/master/OneMonkey.sh'; chmod +x ~/Downloads/OneMonkey.sh; ~/Downloads/OneMonkey.sh\"", s, script];
    NSLog(@"[!] Running command : | %@", concat);
    
}
    // 开始设置iOS的环境
- (IBAction)startSetupForiOS:(id)sender {
}
    // 准备创建工程
- (IBAction)startCreateProject:(id)sender {
}



@end
