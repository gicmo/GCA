//
//  ProgramDayTVC.h
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ProgramDayDelegate;


@interface ProgramDayTVC : UITableViewController
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) id<ProgramDayDelegate> delegate;

+(ProgramDayTVC *)controllerForDay:(NSDate *)date withEvents:(NSArray *)events;

@end


@protocol ProgramDayDelegate <NSObject>
- (void) programDay:(ProgramDayTVC *)programDay didSelectEvent:(NSDictionary *)event;
@end