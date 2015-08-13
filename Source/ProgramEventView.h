//
//  ProgramEventView.h
//  NI2013
//
//  Created by Christian Kellner on 19/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKSchedule.h"

@protocol ProgramEventView
@required
-(void) setEvent:(CKScheduleItem *)event;
@end
