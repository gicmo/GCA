//
//  ProgramDayTVC.h
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CKSchedule.h"

@protocol ProgramDayDelegate;


@interface ProgramDayTVC : UITableViewController
@property (strong, nonatomic, readonly) CKDay *day;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) id<ProgramDayDelegate> delegate;

-(instancetype) initWithDay:(CKDay *)day;
+(ProgramDayTVC *)controllerForDay:(CKDay *)day;

@end


@protocol ProgramDayDelegate <NSObject>
- (void) programDay:(ProgramDayTVC *)programDay didSelectEvent:(NSDictionary *)event;
@end