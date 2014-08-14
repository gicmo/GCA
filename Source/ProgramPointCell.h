//
//  ProgramPointCell.h
//  NI2013
//
//  Created by Christian Kellner on 18/08/2013.
//  Copyright (c) 2013 G-Node. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgramEventView.h"

@interface ProgramPointCell : UITableViewCell <ProgramEventView>
+(CGFloat)heightForEvent:(NSDictionary *)event;
@end
