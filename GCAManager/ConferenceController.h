//
//  ConferenceController.h
//  GCA
//
//  Created by Christian Kellner on 10/08/15.
//  Copyright (c) 2015 G-Node. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Conference.h"

@interface ConferenceController : NSWindowController

@property (weak, nonatomic) Conference *selectedConference;

@end
