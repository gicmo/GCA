//Copyright (c) 2012-2013, German Neuroinformatics Node (G-Node)
//Copyright (c) 2012-2013, Christian Kellner <kellner@bio.lmu.de>
//License: BSD-3 (see LICENSE)

#import <UIKit/UIKit.h>
@protocol ProgramListDelegate;

@interface ProgramListTVC : UIViewController
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) id<ProgramListDelegate> delegate;
@end


@protocol ProgramListDelegate <NSObject>
- (void) programList:(ProgramListTVC *)programList didSelectEvent:(NSDictionary *)event;
@end