//
//  Organization+Format.m
//  AbstractManager
//
//  Created by Christian Kellner on 19/08/14.
//  Copyright (c) 2014 G-Node. All rights reserved.
//

#import "Organization+Format.h"

@implementation Organization (Format)
-(NSString *)mkString
{
    NSMutableArray *components = [[NSMutableArray alloc] init];

    if (self.department) {
        [components addObject:self.department];
    }

    if (self.section) {
        [components addObject:self.section];
    }

    if (self.address) {
        [components addObject:self.address];
    }

    if (self.country) {
        [components addObject:self.country];
    }

    return [components componentsJoinedByString:@", "];
}
@end
