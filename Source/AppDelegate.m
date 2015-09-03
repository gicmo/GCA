//
//  AppDelegate.m
//  NI2013
//
//  Created by Christian Kellner on 17/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import "AppDelegate.h"
#import "CKDataStore.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //this will load the schedule
    CKSchedule *schedule = [[CKDataStore defaultStore] schedule];
    NSLog(@"schedule: %@", schedule);
    return YES;
}

@end
