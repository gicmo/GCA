//
//  AppDelegate.h
//  AbstractManager
//
//  Created by Christian Kellner on 8/8/12.
//  Copyright (c) 2012 G-Node. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSArray *abstracts;

@end
